extends Control

@onready var cardName: Label = $FlowContainer/HBoxContainer/cardName
@onready var gameManager: GameManager = $"../GameManager"
@onready var acc: Label = $FlowContainer/HBoxContainer2/acc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.cardPlayed.connect(onCardPlayed)

func onCardPlayed(card: CardInteractable) -> void:
	cardName.text = "%s de %s" % [CardModel.valueToFileString[card.model.value], CardModel.colorToFileString[card.model.color]]

func _process(delta: float) -> void:
	acc.text = str(gameManager.currentGameAcc)
