class_name GameManager extends Node3D

@onready var deck: Deck = %Deck
@onready var hand: CardHand = %CardHand
@onready var pirateCardHand: CardHand = %PirateCardHand

@onready var playerHandManager: PlayerHandManager = %PlayerHandManager

@onready var centerToAim: Marker3D = %CenterToAim

@onready var pirateModel: PirateModel = %PirateModel


var currentGameTotalScore: int = 0

var playedCardBuffer: Array[CardModel]

var playerScore: int = 0
var pirateScore: int = 0

func _ready() -> void:
	Global.canInteract = false
	
	hand.cardSelected.connect(onCardSelected)
	EventBus.cardPlayed.connect(onCardPlayed)
	EventBus.gameFinished.connect(onGameFinished)
	EventBus.cheatFinish.connect(onCheatFinish)
	
	call_deferred("drawCards", Global.MAX_CARDS_IN_HAND)

func onGameFinished(whoWin: int) -> void:
	Global.gameFinished = true
	
	if whoWin == 0:
		pirateModel.sadLook()
		playerScore += 1
		if playerScore >= Global.GAME_TO_WIN_TO_FINISH:
			onPlayerWin()
			return
		
	else:
		pirateModel.normalLook()
		pirateScore += 1
		if pirateScore >= Global.GAME_TO_WIN_TO_FINISH:
			onPirateWin()
			return
	
	EventBus.resetCurrentGame.emit()
	
	currentGameTotalScore = 0
	deck.askShuffle(true)
	
	await deck.shuffleFinished
	await drawCards(Global.MAX_CARDS_IN_HAND)
	
	pirateModel.normalLook()
	Global.gameFinished = false

func onCheatFinish() -> void:
	Global.gameFinished = true
	Global.gameTrulyFinished = true
	tempoGameFinished()

func onPlayerWin() -> void:
	Global.gameFinished = true
	Global.gameTrulyFinished = true
	tempoGameFinished()
 
func onPirateWin() -> void:
	Global.gameFinished = true
	Global.gameTrulyFinished = true
	tempoGameFinished()

func tempoGameFinished() -> void:
	$"../Pirate/ShakerEmitter3D".emit = true
	
	for cardModel: CardModel in deck.cardsModels:
		var cardInteractable: CardInteractable = GlobalCardManager.getCardInteractableFromModel(cardModel)
		cardInteractable.activate()
		cardInteractable.gravity_scale = 0.2
		cardInteractable.collision_layer = CardInteractable.PHYSICS_LAYER + 0b10
		#cardInteractable.angular_damp = 0.0
		
		Vector3.ZERO.direction_to(cardInteractable.global_position)
		cardInteractable.apply_force(
			Vector3(randf_range(-1.0, 1.0), 0.25, randf_range(-1.0, 1.0)).normalized() * 7000.0, Vector3(5.0, 10.0, 5.0)

			#Vector3.ZERO.direction_to(cardInteractable.global_position) * 5000.0, Vector3(5.0, 10.0, 5.0)
		)
	
	await get_tree().create_timer(1.0).timeout
	for cardModel: CardModel in deck.cardsModels:
		cardModel.cardInteractable.gravity_scale = 1.0
		cardModel.cardInteractable.collision_layer = CardInteractable.PHYSICS_LAYER + 0b01

func drawCards(nb: int) -> void:
	Global.canInteract = false
	Global.drawPhase = true
	
	for i: int in nb:
		var card: CardInteractable = deck.pickTopCard(1)
		card.model.cardOwner = 0
		EventBus.forceStoreCard.emit(card)
		await get_tree().create_timer(0.35).timeout
		
		var pirateCard: CardInteractable = deck.pickTopCard(1)
		pirateCard.model.cardOwner = 1
		pirateCardHand.onForceStoreCard(pirateCard)
		await get_tree().create_timer(0.35).timeout
	
	Global.drawPhase = false
	Global.canInteract = true

func onCardPlayed(card: CardInteractable, who: int) -> void:
	playedCardBuffer.push_back(card.model)
	
	var cardValue: int = card.model.cardScore
	currentGameTotalScore = maxi(0, currentGameTotalScore + cardValue)
	
	#EventBus.gameFinished.emit(1 - who)
	if currentGameTotalScore >= Global.TOTAL_TO_NOT_REACH:
		EventBus.gameFinished.emit(1 - who)
	else:
		if deck.cards.is_empty():
			var cardToExcludeFromReshuffle: Array[CardModel]
			for i: int in range(playedCardBuffer.size() - 1, -1, -1):
				if playedCardBuffer[i].cardOwner == 3 and not playedCardBuffer[i].inHand:
					cardToExcludeFromReshuffle.push_back(playedCardBuffer[i])
					break
			
			deck.askShuffle(false, cardToExcludeFromReshuffle)

func onCardSelected(index: int) -> void:
	var result: Dictionary = RayHelper.castHandCardRay()
	var card: Card = hand.popCard(index)
	
	var cardModelPosition: Vector3 = card.model.global_position
	
	var handPosition: Vector3
	if result:
		handPosition = result.position
	else:
		handPosition = cardModelPosition
	
	var newInteractable: CardInteractable = GlobalCardManager.convertCardHandToInteractableCard(card)
	
	playerHandManager.hold(newInteractable, handPosition)

#func onPlayHand() -> void:
	#Global.isHandActive = false
	#
	#var playedCards: Array[Card]
	#
	#for i: int in range(hand.cards.size() - 1, -1, -1):
		#if hand.cards[i].selected:
			#playedCards.push_back(hand.popCard(i))
	#
	#hand.animationPlayer.play("TuckHand")
	#await hand.animationPlayer.animation_finished
	#animationPlayer.play("SetHandDown")

func playPirateCard(index: int) -> void:
	var card: Card = pirateCardHand.popCard(index)
	var newCardInteractable: CardInteractable = GlobalCardManager.convertCardHandToInteractableCard(card)
	
	sendCardToCenter(newCardInteractable)

func throwPirateCard(index: int) -> void:
	var card: Card = pirateCardHand.popCard(index)
	var newCardInteractable: CardInteractable = GlobalCardManager.convertCardHandToInteractableCard(card)
	
	sendCardToCenter(newCardInteractable)

func sendCardToCenter(cardInteractable: CardInteractable) -> void:
	var direction: Vector3 = cardInteractable.global_position.direction_to(centerToAim.global_position) + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 0.15
	var distance: float = cardInteractable.global_position.distance_to(centerToAim.global_position)
	
	cardInteractable.angular_velocity = Vector3.ZERO
	cardInteractable.linear_velocity = Vector3.ZERO
	cardInteractable.apply_central_force(direction * distance * 200.0)
