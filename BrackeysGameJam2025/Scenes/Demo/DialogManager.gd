class_name DialogManaer extends Node3D


var questionIsAsked: bool = false
var questionChoices: Array[String]
var questionCallback := Callable()

const INITIAL_HIDE_DELAY: float = 2.0
var hideDelay: float = INITIAL_HIDE_DELAY
var shouldHide: bool = false
var isRemnant: bool = false

func _ready() -> void:
	EventBus.dialogFinished.connect(onDialogFinished)
	EventBus.choosenChoice.connect(onChoosenChoice)
	
	EventBus.startSimpleDialog.connect(onStartSimpleDialog)
	EventBus.startRemnantDialog.connect(onStartRemnantDialog)
	EventBus.startQuestionDialog.connect(onStartQuestionDialog)

func reset() -> void:
	if questionIsAsked:
		questionCallback.call(-1)
	
	shouldHide = false
	isRemnant = false
	questionIsAsked = false
	hideDelay = INITIAL_HIDE_DELAY

func onStartSimpleDialog(text: String, angry: bool) -> void:
	reset()
	EventBus.pirateTalk.emit(text, angry)

func onStartRemnantDialog(text: String, angry: bool) -> void:
	reset()
	isRemnant = true
	EventBus.pirateTalk.emit(text, angry)

func onStartQuestionDialog(text: String, angry: bool, choices: Array[String], callback: Callable) -> void:
	reset()
	EventBus.pirateTalk.emit(text, angry)
	
	questionIsAsked = true
	questionChoices = choices
	questionCallback = callback

func onDialogFinished() -> void:
	if questionIsAsked:
		EventBus.pirateAsk.emit(questionChoices)
	elif not isRemnant:
		shouldHide = true

func onChoosenChoice(choice: int) -> void:
	questionIsAsked = false
	
	var callback: Callable = questionCallback
	questionCallback = Callable()
	
	EventBus.clearDialog.emit()
	
	if callback.is_valid(): callback.call(choice)

func _physics_process(delta: float) -> void:
	if shouldHide:
		hideDelay -= delta
		if hideDelay <= 0.0:
			shouldHide = false
			
			EventBus.clearDialog.emit()
			EventBus.simpleDialogFinished.emit()
