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

##DEBUG
@onready var debugui: DebugUI = $"../../DEBUGUI"

func _ready() -> void:
	EventBus.cardAddedInPlayArea.connect(onCardAddedInPlayArea)
	EventBus.cardRemovedFromPlayArea.connect(onCardRemovedFromPlayArea)
	
	deck.topCardPicked.connect(onDeckTopCardPicked)
	
	playerCardHand.cardAdded.connect(onPlayerAddCardToHand)

func getNewThinkingTime() -> float:
	#return 0.0
	var factor: float = 1.0 if turnState == 0 else 0.1
	return randf_range(0.7, 1.5) * factor

func onPlayerAddCardToHand(index: int) -> void:
	if Global.gameFinished: return
	
	if Global.drawPhase:
		playerCardHand.cards[index].model.cardOwner = 0
		return
	
	var cardModel: CardModel = playerCardHand.cards[index].model
	if playerTurn and turnState == 1 and cardModel.cardOwner == 2:
		# OK, Picked from deck, prepare Pirate Turn
		playerTurn = false
		turnState = 0
		cardPlayed = false
		thinkingTime = getNewThinkingTime()
	
	elif cardModel.cardOwner != 0:
		var busted: bool = detectCheat()
		if busted:
			#TODO: Something ?
			cheatResolver(CHEAT_TYPE.STEAL, cardModel)
			return
	
	# Now the card belong to the player
	cardModel.cardOwner = 0

func onCardRemovedFromPlayArea(card: CardInteractable, resolved: bool) -> void:
	if Global.gameFinished: return
	
	if not resolved and card.model.cardOwner == 0:
		# Here the card is not resolved and is owned by the player, so its ok, ignore
		return
	
	var busted: bool = detectCheat()
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
			var busted: bool = detectCheat()
			if busted:
				## CHEAT TRIGGER
				cheatResolver(CHEAT_TYPE.TRY_TO_PLAY_WRONG_TURN, card.model)
				#EventBus.forceStoreCard.emit(card)
				return
		
	else:
		if card.model.cardOwner != 1:
			var busted: bool = detectCheat()
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
			thinkingTime = getNewThinkingTime()
	
	# Now the owner is the table
	EventBus.cardPlayed.emit(card, card.model.cardOwner)
	card.model.cardOwner = 3

func onDeckTopCardPicked(card: CardInteractable, who: int) -> void:
	if Global.gameFinished: return
	
	# If pirate is drawing, ignore
	if who == 1:
		return
	
	if not playerTurn or turnState != 1:
		var busted: bool = detectCheat()
		if busted:
			cheatResolver(CHEAT_TYPE.DECK_STEAL, card.model)
			## TODO: UN TRUC
			return
	
	#TODO: Detecter que le joueur à piocher plusieurs cartes

func detectCheat() -> bool:
	if Global.gameFinished: return false
	
	if distractionManager.isDistracted:
		return false
	
	print("TRICHE ???")
	debugui.cheating()
	return true

enum CHEAT_TYPE {
	DECK_STEAL = 0,
	STEAL = 1,
	TRY_TO_PLAY_WRONG_TURN = 2
}

func cheatResolver(cheatType: CHEAT_TYPE, cardModel: CardModel) -> void:
	if Global.gameFinished: return
	
	#match cheatType:
		#CHEAT_TYPE.DECK_STEAL:
			##TODO: A partir d'un model, récupérer la position de la carte et sa version CardInteractable
			#var cardInteractable: CardInteractable = GlobalCardManager.getCardInteractableFromModel(cardModel)
			#deck.addOnTop(cardInteractable)
	
	var cardInteractable: CardInteractable = GlobalCardManager.getCardInteractableFromModel(cardModel)
	
	# Player
	if cardModel.cardOwner == 0:
		EventBus.forceStoreCard.emit(cardInteractable)
	
	# Deck
	elif cardModel.cardOwner == 2:
		deck.addOnTop(cardInteractable)
	
	# Table or Pirate
	elif cardModel.cardOwner == 3 or cardModel.cardOwner == 1:
		gameManager.sendCardToCenter(cardInteractable)

var thinkingTime: float
var cardPlayed: bool = false
func _physics_process(delta: float) -> void:
	if Global.gameFinished: return
	
	if not playerTurn:
		thinkingTime -= delta
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
	var bestTotal: int = 0
	
	for i: int in pirateCardHand.cards.size():
		var newTotal: int = currentTotal + pirateCardHand.cards[i].model.cardScore
		
		if newTotal > bestTotal and newTotal < Global.TOTAL_TO_NOT_REACH:
			bestIndex = i
			bestTotal = newTotal
	
	return bestIndex
