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
	
	AS
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
	
	VALUE.AS: "as"
}

static var colorToFileString: Dictionary[COLOR, String] = {
	COLOR.SPADES: "pique",
	COLOR.CLUBS: "trefle",
	COLOR.DIAMONDS: "carreau",
	COLOR.HEARTS: "coeur"
}

@export var color: COLOR
@export var value: VALUE

@onready var meshInstance: MeshInstance3D = $MeshInstance3D
@onready var shaderMaterial: ShaderMaterial = meshInstance.material_override

func _ready() -> void:
	shaderMaterial.set_shader_parameter("frontTexture", load("res://Resources/Assets/Cards/Textures/%s_%s.png" % [valueToFileString[value], colorToFileString[color]]))
