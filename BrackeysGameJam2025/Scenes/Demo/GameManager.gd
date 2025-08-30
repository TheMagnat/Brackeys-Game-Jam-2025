class_name GameManager extends Node3D

@onready var deck: Deck = %Deck
@onready var hand: CardHand = %CardHand
@onready var pirateCardHand: CardHand = %PirateCardHand

@onready var playerHandManager: PlayerHandManager = %PlayerHandManager

@onready var centerToAim: Marker3D = %CenterToAim

@onready var pirateModel: PirateModel = %PirateModel

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

var currentGameTotalScore: int = 0

var playedCardBuffer: Array[CardModel]

var playerScore: int = 0
var pirateScore: int = 0

func _ready() -> void:
	Global.canInteract = false
	
	EventBus.skipIntroduction.connect(onSkipIntroduction)
	
	hand.cardSelected.connect(onCardSelected)
	EventBus.cardPlayed.connect(onCardPlayed)
	EventBus.gameFinished.connect(onGameFinished)
	EventBus.cheatFinish.connect(onCheatFinish)

@onready var cookieArea: Node3D = %CookieArea

var showCookieAreaTween: Tween
func showCookieArea() -> void:
	showCookieAreaTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	showCookieAreaTween.tween_property(cookieArea, "position:x", -70.0, 3.0)

const YES : Array[String] = [
	"Yes", "Sure", "For sure", "Aye"
]

const NO : Array[String] = [
	"No", "Nope", "Nae", "Certainly not"
]

const RETRY : Array[String] = [
	"Retry", "Play again", "Take a new chance", "Try another approach", "Hope for something better", "Try again"
]

var introductionFinished: bool = false
func onSkipIntroduction() -> void:
	introductionFinished = true
	EventBus.clearDialog.emit()
	EventBus.choosenChoice.emit(-1)
	showCookieArea()
	startGame()

func startIntroduction1() -> void:
	EventBus.introductionStarted.emit()
	
	if introductionFinished: return
	
	for dialog in PirateDialogs.introductionText:
		EventBus.startSimpleDialog.emit(dialog, false)
		await EventBus.simpleDialogFinished
		
		if introductionFinished: return
	
	EventBus.startQuestionDialog.emit(PirateDialogs.introductionQuestion, false, [YES.pick_random(), NO.pick_random()] as Array[String], introduction1Answer)

func introduction1Answer(answer: int) -> void:
	if introductionFinished: return
	
	if answer == 1:
		startTutorial()
		return
	
	startIntroduction2()
	
func startIntroduction2() -> void:
	if introductionFinished: return
	
	for dialog in PirateDialogs.introduction2Text:
		if dialog == PirateDialogs.introduction2Text[3]:
			showCookieArea()
		
		EventBus.startSimpleDialog.emit(dialog, false)
		await EventBus.simpleDialogFinished
		
		if introductionFinished: return
	
	if introductionFinished: return
	
	EventBus.startQuestionDialog.emit(PirateDialogs.introduction2Question, false, PirateDialogs.introduction2Offers, introduction2Answer)

var intro2State: int = -1
func introduction2Answer(answer: int) -> void:
	if introductionFinished: return
	
	if intro2State == -1:
		if answer == 2:
			startIntroduction3()
			return
		
		var answers: Array[String] = PirateDialogs.introduction2Offers.duplicate()
		var angry: bool = false
		if answer == 0:
			intro2State = 0
			answers.remove_at(0)
		else:
			intro2State = 1
			answers.remove_at(1)
			angry = true
		
		EventBus.startQuestionDialog.emit(PirateDialogs.introduction2Answers[answer], angry, answers, introduction2Answer)
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
		
		EventBus.startQuestionDialog.emit(PirateDialogs.introduction2Answers[subIndex], angry, answers, startIntroduction3)

func startIntroduction3(_answer: int = 0) -> void:
	introductionFinished = true
	EventBus.introductionFinished.emit()
	
	EventBus.startSimpleDialog.emit(PirateDialogs.introduction2Answers[2], false)
	await EventBus.simpleDialogFinished
	
	startGame()

func startTutorial(angry: bool = false) -> void:
	if introductionFinished: return
	
	for dialog in PirateDialogs.tutorialText:
		EventBus.startSimpleDialog.emit(dialog, angry)
		await EventBus.simpleDialogFinished
		
		if introductionFinished: return
	
	if angry:
		tutorialPart2(0)
		return
	
	EventBus.startQuestionDialog.emit(PirateDialogs.tutorialQuestion, angry, [YES.pick_random(), NO.pick_random()] as Array[String], tutorialPart2)

var repeatCount: int = 0
func tutorialPart2(answer: int) -> void:
	if introductionFinished: return
	
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
	EventBus.startSimpleDialog.emit(PirateDialogs.startGame, false)
	await EventBus.simpleDialogFinished
	
	call_deferred("drawCards", Global.MAX_CARDS_IN_HAND)

const WINNER_PLAYER := 0
const WINNER_PIRATE := 1

func onGameFinished(whoWin: int) -> void:
	Global.gameFinished = true
	Global.canInteract = false
	
	var dialogString := ""
	if whoWin == WINNER_PLAYER:
		dialogString += PirateDialogs.pirateLost.pick_random()
		pirateModel.sadLook()
		playerScore += 1
		if playerScore >= Global.GAME_TO_WIN_TO_FINISH:
			onPlayerWin()
			return
		
	else:
		dialogString += PirateDialogs.pirateWin.pick_random()
		pirateModel.normalLook()
		pirateScore += 1
		if pirateScore >= Global.GAME_TO_WIN_TO_FINISH:
			onPirateWin()
			return
	
	EventBus.resetCurrentGame.emit()
	
	dialogString += "\n" + PirateDialogs.points.pick_random() % [playerScore, pirateScore]
	EventBus.startQuestionDialog.emit(dialogString, false, [YES.pick_random()] as Array[String], restartGame)

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
	
	EventBus.startQuestionDialog.emit(PirateDialogs.cheatGameOver.pick_random(), true, [RETRY.pick_random()] as Array[String], onRetry)
	explodeCards()

func onPlayerWin() -> void:
	Global.gameFinished = true
	Global.gameTrulyFinished = true
	#explodeCards()
	playerWinEvent()
 
func onPirateWin() -> void:
	Global.gameFinished = true
	Global.gameTrulyFinished = true
	EventBus.startQuestionDialog.emit(PirateDialogs.finalPirateWin.pick_random(), true, [RETRY.pick_random()] as Array[String], onRetry)

func onRetry(_choice: int) -> void:
	animationPlayer.play_backwards("OpenScene")
	await animationPlayer.animation_finished
	
	get_tree().reload_current_scene()

func explodeCards() -> void:
	$"../Pirate/ShakerEmitter3D".emit = true
	
	for cardModel: CardModel in deck.cardsModels:
		var cardInteractable: CardInteractable = Global.cardManager.getCardInteractableFromModel(cardModel)
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

func playerWinEvent() -> void:
	for dialog in PirateDialogs.winningDialog:
		EventBus.startSimpleDialog.emit(dialog, false)
		await EventBus.simpleDialogFinished
	
	EventBus.startQuestionDialog.emit(PirateDialogs.joinCrewQuestion, true, [YES.pick_random(), NO.pick_random()] as Array[String], playerWinEventAnswer)


@onready var OUTRO := $"../Outro"
func playerWinEventAnswer(answer: int) -> void:
	if answer == 0:
		# If yes (good ending)
		EventBus.startSimpleDialog.emit(PirateDialogs.joinCrewAccept, false)
		Global.goodEnding = true
		
	else:
		# If no (bad ending)
		EventBus.startSimpleDialog.emit(PirateDialogs.joinCrewRefuse, true)
		Global.goodEnding = false
	
	await EventBus.simpleDialogFinished
	OUTRO.start(Global.goodEnding)

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
	
	var newInteractable: CardInteractable = Global.cardManager.convertCardHandToInteractableCard(card)
	
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
	var newCardInteractable: CardInteractable = Global.cardManager.convertCardHandToInteractableCard(card)
	
	sendCardToCenter(newCardInteractable)

func throwPirateCard(index: int) -> void:
	var card: Card = pirateCardHand.popCard(index)
	var newCardInteractable: CardInteractable = Global.cardManager.convertCardHandToInteractableCard(card)
	
	sendCardToCenter(newCardInteractable)

func sendCardToCenter(cardInteractable: CardInteractable) -> void:
	var direction: Vector3 = cardInteractable.global_position.direction_to(centerToAim.global_position) + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 0.15
	var distance: float = cardInteractable.global_position.distance_to(centerToAim.global_position)
	
	cardInteractable.angular_velocity = Vector3.ZERO
	cardInteractable.linear_velocity = Vector3.ZERO
	cardInteractable.apply_central_force(direction * distance * 200.0)
