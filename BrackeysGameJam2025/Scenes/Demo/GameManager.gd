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
	
	if Debug.DEBUG:
		startGame()
		return
	
	call_deferred("startIntroduction1")

const YES : Array[String] = [
	"Yes", "Sure", "For sure", "Aye"
]

const NO : Array[String] = [
	"No", "Nope", "Nae", "Certainly not"
]

func startIntroduction1() -> void:
	EventBus.startSimpleDialog.emit(PirateDialogs.introductionText[0], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introductionText[1], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introductionText[2], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introductionText[3], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introductionText[4], false)
	await EventBus.simpleDialogFinished
	
	EventBus.startQuestionDialog.emit(PirateDialogs.introductionText[5], false, [YES.pick_random(), NO.pick_random()] as Array[String], introduction1Answer)

func introduction1Answer(answer: int) -> void:
	if answer == 1:
		startTutorial()
		return
	
	startIntroduction2()
	
func startIntroduction2() -> void:
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction2Text[0], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction2Text[1], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction2Text[2], false)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction2Text[3], false)
	await EventBus.simpleDialogFinished
	
	EventBus.startQuestionDialog.emit(PirateDialogs.introduction2Text[4], false, PirateDialogs.introduction2Answers, introduction2Answer)

var intro2State: int = -1
func introduction2Answer(answer: int) -> void:
	if intro2State == -1:
		if answer == 2:
			startIntroduction3()
			return
		
		var answers: Array[String] = PirateDialogs.introduction2Answers.duplicate()
		var subIndex: int
		var angry: bool = false
		if answer == 0:
			intro2State = 0
			answers.remove_at(0)
			subIndex = 0
		else:
			intro2State = 1
			answers.remove_at(1)
			subIndex = 1
			angry = true
		
		EventBus.startQuestionDialog.emit(PirateDialogs.subIntroduction2Text[subIndex], angry, answers, introduction2Answer)
	
	else:
		if answer == 1:
			startIntroduction3()
			return
		
		var answers: Array[String] = [PirateDialogs.introduction2Answers[2]]
		var subIndex: int
		var angry: bool = false
		if intro2State == 0:
			angry = true
			subIndex = 1
		else:
			subIndex = 0
		
		EventBus.startQuestionDialog.emit(PirateDialogs.subIntroduction2Text[subIndex], angry, answers, startIntroduction3)

func startIntroduction3(_answer: int = 0) -> void:
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction3Text[0], false)
	await EventBus.simpleDialogFinished
	
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction3Text[1], false)
	await EventBus.simpleDialogFinished
	
	startGame()

func startTutorial(angry: bool = false) -> void:
	EventBus.startSimpleDialog.emit(PirateDialogs.tutorialText[0], angry)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.tutorialText[1], angry)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.tutorialText[2], angry)
	await EventBus.simpleDialogFinished
	EventBus.startSimpleDialog.emit(PirateDialogs.tutorialText[3], angry)
	await EventBus.simpleDialogFinished
	
	if angry:
		tutorialPart2(0)
		return
	
	EventBus.startQuestionDialog.emit(PirateDialogs.tutorialText[4], angry, [YES.pick_random(), NO.pick_random()] as Array[String], tutorialPart2)

var repeatCount: int = 0
func tutorialPart2(answer: int) -> void:
	if answer == 1 and repeatCount < 2:
		var angry: bool
		if repeatCount == 0:
			angry = false
			EventBus.startSimpleDialog.emit(PirateDialogs.tutorialRepeat, false)
		else:
			angry = true
			EventBus.startSimpleDialog.emit(PirateDialogs.tutorialRepeatAngry, true)
		
		repeatCount += 1
		await EventBus.simpleDialogFinished
		startTutorial(angry)
		return
	
	startIntroduction2()

func startGame() -> void:
	call_deferred("drawCards", Global.MAX_CARDS_IN_HAND)

func onGameFinished(whoWin: int) -> void:
	Global.gameFinished = true
	Global.canInteract = false
	
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
	
	EventBus.startQuestionDialog.emit("La partie est terminé, %d - %d pour toi. Prêt pour continuer ?" % [playerScore, pirateScore], false, [YES.pick_random()] as Array[String], restartGame)

func restartGame(_answer: int = 0) -> void:
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
	var cardValue: int = card.model.cardScore
	currentGameTotalScore = maxi(0, currentGameTotalScore + cardValue)
	
	#EventBus.gameFinished.emit(1 - who)
	if currentGameTotalScore >= Global.TOTAL_TO_NOT_REACH:
		EventBus.gameFinished.emit(1 - who)
		return
	
	if who == 1:
		EventBus.startRemnantDialog.emit(PirateDialogs.count.pick_random() % currentGameTotalScore, false)
	else:
		EventBus.startSimpleDialog.emit(PirateDialogs.playing.pick_random(), false)
	
	card.model.cardOwner = 3
	playedCardBuffer.push_back(card.model)
	
	if deck.cards.is_empty():
		var cardToExcludeFromReshuffle: Array[CardModel]
		#TODO: Maybe useless since push_back is just above ??
		for i: int in range(playedCardBuffer.size() - 1, -1, -1):
			if playedCardBuffer[i].cardOwner == 3 and not playedCardBuffer[i].inHand:
				cardToExcludeFromReshuffle.push_back(playedCardBuffer[i])
				break
		
		EventBus.startSimpleDialog.emit(PirateDialogs.shuffleCards.pick_random(), false)
		
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
