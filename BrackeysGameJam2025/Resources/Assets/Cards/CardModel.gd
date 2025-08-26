@tool
class_name CardModel extends Node3D

enum COLOR {
	SPADES = 0, # Pique
	CLUBS = 1, # Trèfles
	DIAMONDS = 2, # Carreaux
	HEARTS = 3 # Coeurs
}

enum VALUE {
	TWO = 0,
	THREE = 1,
	FOUR = 2,
	FIVE = 3,
	SIX = 4,
	SEVEN = 5,
	EIGHT = 6,
	NINE = 7,
	TEN = 8,
	JACK = 9,
	QUEEN = 10,
	KING = 11,
	AS = 12
}

const valueToScore: Dictionary[CardModel.VALUE, int] = {
	CardModel.VALUE.AS: 1,
	CardModel.VALUE.TWO: 2,
	CardModel.VALUE.THREE: 3,
	CardModel.VALUE.FOUR: 4,
	CardModel.VALUE.FIVE: 5,
	CardModel.VALUE.SIX: 6,
	CardModel.VALUE.SEVEN: 7,
	CardModel.VALUE.EIGHT: 8,
	CardModel.VALUE.NINE: 9,
	CardModel.VALUE.TEN: 10,
	CardModel.VALUE.JACK: -10,
	CardModel.VALUE.QUEEN: 0,
	CardModel.VALUE.KING: -20
}

static var valueToFileString: Dictionary[VALUE, String] = {
	VALUE.TWO: "2",
	VALUE.THREE: "3",
	VALUE.FOUR: "4",
	VALUE.FIVE: "5",
	VALUE.SIX: "6",
	VALUE.SEVEN: "7",
	VALUE.EIGHT: "8",
	VALUE.NINE: "9",
	VALUE.TEN: "10",
	VALUE.JACK: "valet",
	VALUE.QUEEN: "reine",
	VALUE.KING: "roi",
	VALUE.AS: "as"
}
const NB_VALUE: int = 13

static var colorToFileString: Dictionary[COLOR, String] = {
	COLOR.SPADES: "pique",
	COLOR.CLUBS: "trefle",
	COLOR.DIAMONDS: "carreau",
	COLOR.HEARTS: "coeur"
}

## Status, to help find it in the world
var inHand: bool = false
var hand: CardHand
var handCard: Card
var cardInteractable: CardInteractable = null

var cardId: int
@export var color: COLOR
@export var value: VALUE
var cardScore: int
var cardOwner: int = 0 # 0 = Player, 1 = Pirate, 2 = deck, 3 = table

func setColorAndValueFromId(cardIdParam: int) -> void:
	cardId = cardIdParam
	color = (cardId / NB_VALUE) as COLOR
	value = (cardId - color * NB_VALUE) as VALUE
	
	cardScore = valueToScore[value]

@onready var meshInstance: MeshInstance3D = $MeshInstance3D
@onready var shaderMaterial: ShaderMaterial = meshInstance.material_override

func _ready() -> void:
	cardId = value + color * NB_VALUE
	cardScore = valueToScore[value]
	
	# Rendering
	shaderMaterial.set_shader_parameter("frontTexture", load("res://Resources/Assets/Cards/Textures/%s_%s.png" % [valueToFileString[value], colorToFileString[color]]))
