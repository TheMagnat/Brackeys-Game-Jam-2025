extends Node

## Game Knowledge
var playerTurn: bool = true
var turnState: int = 0 # 0 = Play card, 1 = draw card

@onready var gameManager: GameManager = %GameManager
@onready var deck: Deck = %Deck
@onready var pirateCardHand: CardHand = %PirateCardHand
@onready var playerCardHand: CardHand = %CardHand
@onready var centerToAim: Marker3D = %CenterToAim
@onready var table: Table = %Table
@onready var distractionManager: DistractionManager = $"../DistractionManager"

@onready var pirateModel: PirateModel = %PirateModel

##DEBUG
@onready var debugui: DebugUI = $"../../DEBUGUI"

func _ready() -> void:
	EventBus.cardAddedInPlayArea.connect(onCardAddedInPlayArea)
	EventBus.cardRemovedFromPlayArea.connect(onCardRemovedFromPlayArea)
	EventBus.deckCardInPlayArea.connect(onDeckCardInPlayArea)
	EventBus.droppedItem.connect(onDroppedItem)
	EventBus.resetCurrentGame.connect(onResetCurrentGame)
	EventBus.pickedGroundCard.connect(onGroundCardPicked)
	
	deck.topCardPicked.connect(onDeckTopCardPicked)
	deck.topCardAdded.connect(onDeckTopCardAdded)
	
	playerCardHand.cardAdded.connect(onPlayerAddCardToHand)

func onResetCurrentGame() -> void:
	playerTurn = true
	turnState = 0
	getNewThinkingTime(2.0)

func moveToPirateTurn() -> void:
	playerTurn = false
	turnState = 0
	cardPlayed = false
	eyeDown = false
	eyeUp = false
	getNewThinkingTime()

func getNewThinkingTime(factor: float = 1.0, offset: float = 0.0) -> void:
	thinkingTime = randf_range(1.5, 2.5) * factor
	eyeDownTime = thinkingTime * 0.2 + offset
	eyeUpTime = thinkingTime * 0.9 + offset
	
	thinkingTime += offset
	
	return

func onGroundCardPicked(card: CardInteractable) -> void:
	if Global.gameFinished: return
	
	var busted: bool = detectCheat(false)
	if busted:
		# Make the card now owned by the deck, so the pirate will steal it
		card.model.cardOwner = 2
		cheatResolver(CHEAT_TYPE.TRY_PICK_GROUND_CARD, card.model)

func onDroppedItem(object: Interactable) -> void:
	if Global.gameFinished: return
	
	if object is CardInteractable:
		var card: CardInteractable = object
		if card.cardIsHidden:
			var busted: bool = detectCheat(false)
			if busted:
				cheatResolver(CHEAT_TYPE.HIDE, card.model)
			

func onDeckCardInPlayArea(card: CardInteractable) -> void:
	deck.addOnTop(card, 1)

func onPlayerAddCardToHand(index: int, who: int) -> void:
	if Global.gameFinished: return
	
	var cardModel: CardModel = playerCardHand.cards[index].model
	
	# Pirate initated this so ignore
	if who == 1:
		cardModel.cardOwner = 0
		return
	
	if Global.drawPhase:
		cardModel.cardOwner = 0
		return
	
	if playerTurn and turnState == 1 and cardModel.cardOwner == 2:
		# OK, Picked from deck, prepare Pirate Turn
		moveToPirateTurn()
	
	elif cardModel.cardOwner != 0:
		var busted: bool = detectCheat(true)
		if busted:
			#TODO: Something ?
			cheatResolver(CHEAT_TYPE.STEAL, cardModel)
			return
	
	# Now the card belong to the player
	cardModel.cardOwner = 0

func onCardRemovedFromPlayArea(card: CardInteractable, resolved: bool) -> void:
	if Global.gameFinished: return
	
	if card.model.cardOwner == 2:
		# If card is owned by the deck, let the game put it back on top of it
		return
	
	if not resolved and card.model.cardOwner == 0:
		# Here the card is not resolved and is owned by the player, so its ok, ignore
		return
	
	var busted: bool = detectCheat(false)
	if busted:
		cheatResolver(CHEAT_TYPE.STEAL, card.model)

func onCardAddedInPlayArea(card: CardInteractable) -> void:
	if Global.gameFinished: return
	
	if playerTurn:
		if card.model.cardOwner != 0:
			print("CHELOU ???")
			printerr("Player turn but nor player card ?")
			#TODO: Un truc ?
			return
		
		if turnState == 0:
			turnState = 1
		else:
			var busted: bool = detectCheat(true)
			if busted:
				## CHEAT TRIGGER
				cheatResolver(CHEAT_TYPE.TRY_TO_PLAY_WRONG_TURN, card.model)
				#EventBus.forceStoreCard.emit(card)
				return
		
	else:
		if card.model.cardOwner != 1:
			var busted: bool = detectCheat(true)
			if busted:
				## CHEAT TRIGGER
				EventBus.forceStoreCard.emit(card)
				return
			
			# Not busted, do something ?
			card.model.cardOwner = 3
			return
		
		if turnState == 0:
			# Pirate played his card, update turn state
			turnState = 1
			getNewThinkingTime(0.2)
	
	EventBus.cardPlayed.emit(card, card.model.cardOwner)
	
	# Now the owner is the table (Maybe useless since the GameManager does it too)
	card.model.cardOwner = 3

func onDeckTopCardAdded(card: CardInteractable, who: int) -> void:
	if Global.gameFinished: return
	
	if who != 0:
		# If the player is not the one who initiated this move, ignore
		return
	
	if card.model.cardOwner != 2:
		# Here the player try to add in deck a card that is already in game
		var busted: bool = detectCheat(true)
		if busted:
			# Also remove the card from the deck
			deck.pickTopCard(1)
			cheatResolver(CHEAT_TYPE.HIDE_IN_DECK, card.model)
			return
		
		# Here the cheat is not detected, so now the card belong to the deck
		card.model.cardOwner = 2

func onDeckTopCardPicked(card: CardInteractable, who: int) -> void:
	if Global.gameFinished: return
	
	# If pirate is drawing, ignore
	#if who == 1:
		#return
	#
	#if not playerTurn or turnState != 1:
		#var busted: bool = detectCheat()
		#if busted:
			#cheatResolver(CHEAT_TYPE.DECK_STEAL, card.model)
			### TODO: UN TRUC
			#return
	
	#TODO: Detecter que le joueur à piocher plusieurs cartes

var nbCheatDetected: int = 0
const cheatLimitToExplode: int = 3

var nbCheatSinceDistracted: int = 0
const maxCheatPerDistraction: int = 2

var nbLostCardTrigger: int = 0
var lastLostTriggerNbMissingCards: int = 0
func analyseGameState() -> void:
	if Global.gameFinished: return
	#TODO: Mettre un delay de temps d'analyse
	
	var visibleCards: Array[CardModel]
	for cardModel: CardModel in CardModel.playerCardTracker:
		if cardModel.inHand:
			visibleCards.push_back(cardModel)
		
		elif cardModel.cardInteractable.isVisible():
			visibleCards.push_back(cardModel)
	
	var nbCardsToRemove: int
	
	var isPlayerDrawTurn: bool = false
	if playerTurn and turnState == 1:
		isPlayerDrawTurn = true
		nbCardsToRemove = visibleCards.size() - (Global.MAX_CARDS_IN_HAND - 1)
		
	else:
		nbCardsToRemove = visibleCards.size() - Global.MAX_CARDS_IN_HAND

	
	if nbCardsToRemove > 0:
		# Here the pirate saw that the player have more than 4 cards (or 3 if he need to pick a card)
		#TODO: If in state 1 and now have 4, maybe pass state to pirate turn ?
		if isPlayerDrawTurn and nbCardsToRemove == 1:
			moveToPirateTurn()
			return
		
		# When onCheatDetected return false, the game is over
		if not onCheatDetected(): return
		
		tooMuchCardsCheatResolver(visibleCards, nbCardsToRemove)
	
	elif nbCardsToRemove < 0:
		if nbLostCardTrigger > 0:
			var precedentNb: int = lastLostTriggerNbMissingCards
			lastLostTriggerNbMissingCards = abs(nbCardsToRemove)
			
			if precedentNb >= lastLostTriggerNbMissingCards:
				# To prevent repeating this event even if the nb missing not changed between method trigger
				return
			
			if visibleCards.size() == 0:
				# To prevent soft lock if 0 cards in hand, finish the game on a cheat
				onCheatFinishGame()
				return
			
			nbLostCardTrigger += 1
			EventBus.startSimpleDialog.emit(PirateDialogs.notEnoughCardsAngry.pick_random(), true)
			onCheatDetected()
			return
		
		# Here the player "lost" cards, maybe force him to draw some ?
		EventBus.startSimpleDialog.emit(PirateDialogs.notEnoughCards.pick_random(), false)
		
		nbLostCardTrigger += 1
		
		for i: int in abs(nbCardsToRemove):
			var newCard: CardInteractable = deck.pickTopCard(1)
			EventBus.forceStoreCard.emit(newCard)
	
func detectCheat(addToDistractedCount: bool) -> bool:
	if Global.gameFinished: return false
	
	if distractionManager.isDistracted:
		
		if addToDistractedCount:
			nbCheatSinceDistracted += 1
			if nbCheatSinceDistracted >= maxCheatPerDistraction:
				distractionManager.stopDistraction()
		
		return false
	
	return onCheatDetected()

func onCheatDetected() -> bool:
	pirateModel.lookPlayer()
	eyeDown = false
	eyeUp = false
	getNewThinkingTime(1.0, 2.0)
	
	nbCheatDetected += 1
	if nbCheatDetected >= cheatLimitToExplode:
		onCheatFinishGame()
		return false
	
	if nbCheatDetected == 1:
		pirateModel.onFirstCheatDetected()
	else:
		pirateModel.onCheatDetected()
	
	#TODO: Remove
	debugui.cheating()
	return true

func onCheatFinishGame() -> void:
	Global.canInteract = false
	
	for i: int in pirateCardHand.cards.size():
		gameManager.playPirateCard(0)
	
	pirateModel.explode()
	await pirateModel.animationPlayer.animation_finished
	
	Global.canInteract = true
	
	EventBus.cheatFinish.emit()

enum CHEAT_TYPE {
	STEAL = 0,
	HIDE = 1,
	HIDE_IN_DECK = 2,
	TRY_TO_PLAY_WRONG_TURN = 3,
	TRY_PICK_GROUND_CARD = 4,

	TOO_MUCH_CARDS = 5
}

func cheatResolver(cheatType: CHEAT_TYPE, cardModel: CardModel) -> void:
	if Global.gameFinished: return
	
	EventBus.startSimpleDialog.emit("Tu triche enculé. Tu peux modifier la phrase ici en fonction du type de triche.", true)
	
	var cardInteractable: CardInteractable = GlobalCardManager.getCardInteractableFromModel(cardModel)
	
	# Player
	if cardModel.cardOwner == 0:
		EventBus.forceStoreCard.emit(cardInteractable)
	
	# Deck
	elif cardModel.cardOwner == 2:
		#deck.addOnTop(cardInteractable, 1)
		
		# The pirate confiscate the card as a punition
		cardModel.cardOwner = 1 
		pirateCardHand.onForceStoreCard(cardInteractable)
	
	# Table or Pirate
	elif cardModel.cardOwner == 3 or cardModel.cardOwner == 1:
		gameManager.sendCardToCenter(cardInteractable)

func tooMuchCardsCheatResolver(visibleCards: Array[CardModel], nbCardsToRemove: int) -> void:
	if Global.gameFinished: return
	
	EventBus.startSimpleDialog.emit(PirateDialogs.tooManyCards.pick_random(), true)
	
	Global.canInteract = false
	
	for i: int in nbCardsToRemove:
		var cardIndex: int = randi_range(0, visibleCards.size() - 1)
		var cardModelToSteal: CardModel = visibleCards.pop_at(cardIndex)
		
		var card: CardInteractable = GlobalCardManager.getCardInteractableFromModel(cardModelToSteal)
		card.model.cardOwner = 1 
		pirateCardHand.onForceStoreCard(card)
		
		await get_tree().create_timer(0.25).timeout
	
	Global.canInteract = true
	return

var thinkingTime: float
var eyeDownTime: float
var eyeUpTime: float
var cardPlayed: bool = false
var eyeDown: bool = false
var eyeUp: bool = false

var wasDistracted: bool = false
func _physics_process(delta: float) -> void:
	if Global.gameFinished: return
	
	if distractionManager.isDistracted:
		wasDistracted = true
		return
	
	elif wasDistracted:
		wasDistracted = false
		eyeDown = false
		eyeUp = false
		nbCheatSinceDistracted = 0
		getNewThinkingTime()
		analyseGameState()
	
	if not playerTurn:
		thinkingTime -= delta
		
		if turnState == 0:
			eyeDownTime -= delta
			if eyeDownTime <= 0.0:
				eyeDown = true
				pirateModel.lookCards()
			
			eyeUpTime -= delta
			if eyeUpTime <= 0.0:
				eyeUp = true
				pirateModel.lookPlayer()
		
		if thinkingTime <= 0.0:
			if turnState == 0 and not cardPlayed:
				var cardToPlay: int = selectCard()
				
				if cardToPlay == -1:
					EventBus.gameFinished.emit(0)
					return
				
				gameManager.playPirateCard(cardToPlay)
				cardPlayed = true
				#TODO: ANTI-SOFTLOCK Delay check after card played
			elif turnState == 1:
				var pirateCard: CardInteractable = deck.pickTopCard(1)
				pirateCard.model.cardOwner = 1
				pirateCardHand.onForceStoreCard(pirateCard)
				
				playerTurn = true
				turnState = 0

func selectCard() -> int:
	var currentTotal: int = gameManager.currentGameTotalScore
	
	var bestIndex: int = -1
	var bestTotal: int = -1000
	
	for i: int in pirateCardHand.cards.size():
		var newTotal: int = currentTotal + pirateCardHand.cards[i].model.cardScore
		
		if newTotal > bestTotal and newTotal < Global.TOTAL_TO_NOT_REACH:
			bestIndex = i
			bestTotal = newTotal
	
	return bestIndex

func _on_off_table_detector_body_entered(body: Node3D) -> void:
	if Global.gameFinished: return
	
	var card: CardInteractable = body
	
	var busted: bool = detectCheat(true)
	if busted:
		cheatResolver(CHEAT_TYPE.HIDE, card.model)
