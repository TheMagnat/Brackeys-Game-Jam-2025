class_name DebugUI extends Control

@onready var cardName: Label = $FlowContainer/HBoxContainer/cardName
@onready var gameManager: GameManager = $"../GameManager"
@onready var acc: Label = $FlowContainer/HBoxContainer2/acc
@onready var cheatLabel: Label = $FlowContainer/HBoxContainer3/cheatLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.cardPlayed.connect(onCardPlayed)

func onCardPlayed(card: CardInteractable, who: int) -> void:
	cardName.text = "%s de %s" % [CardModel.valueToFileString[card.model.value], CardModel.colorToFileString[card.model.color]]

func _process(delta: float) -> void:
	acc.text = str(gameManager.currentGameTotalScore)
	cheatingTime -= delta
	if cheatingTime <= 0.0:
		cheatLabel.text = ""

var cheatingTime: float = 0.0
func cheating() -> void:
	cheatLabel.text = "CHEAT !!!"
	cheatingTime = 2.0
