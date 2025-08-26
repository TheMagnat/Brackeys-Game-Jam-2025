extends Node3D


var cards: Array[CardInteractable]

var count: int = 32
const randomRotation: float = PI / 32.0

const CARD_COLLISION_SHAPE: BoxShape3D = preload("uid://bm58nbans4mp1")
const CARD_MODEL = preload("uid://dnqbvrx07oldi")

func _ready() -> void:
	var cardStep: float = CARD_COLLISION_SHAPE.size.z
	var startPos: float = cardStep / 2.0
	for i: int in count:
		var card := CardInteractable.new()
		card.rotation = Vector3(PI / 2.0, PI + randf_range(-randomRotation, randomRotation), 0.0)
		card.position.y = startPos + i * cardStep
		card.activated = false
		card.cardIsHidden = true
		
		var collisionShape := CollisionShape3D.new()
		collisionShape.shape = CARD_COLLISION_SHAPE
		
		card.add_child(collisionShape)
		add_child(card)
		
		var cardModel: CardModel = CARD_MODEL.instantiate()
		card.initializeNewModel(cardModel)
		
		cards.push_back(card)
		
	
	# Connect last card from the deck
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)

func onTopCardPicked() -> void:
	cards[-1].picked.disconnect(onTopCardPicked)
	cards.pop_back()
	
	if not cards.is_empty():
		cards[-1].activate()
		cards[-1].picked.connect(onTopCardPicked)
