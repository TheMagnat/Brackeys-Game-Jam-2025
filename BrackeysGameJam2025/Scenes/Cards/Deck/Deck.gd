class_name Deck extends Node3D

signal topCardPicked(card: CardInteractable, who: int)

var cards: Array[CardInteractable]
var cardsModels: Array[CardModel]

var count: int = 52
const randomRotation: float = PI / 32.0

const CARD_COLLISION_SHAPE: BoxShape3D = preload("uid://bm58nbans4mp1")
const CARD_MODEL = preload("uid://dnqbvrx07oldi")

func _ready() -> void:
	var indices: Array[int]
	indices.assign(range(count))
	indices.shuffle()
	
	var cardStep: float = CARD_COLLISION_SHAPE.size.z / 2.0
	var startPos: float = cardStep / 2.0
	for i: int in indices.size():
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
		cardModel.setColorAndValueFromId(indices[i])
		cardModel.cardOwner = 2
		
		card.initializeNewModel(cardModel)
		
		cards.push_back(card)
		cardsModels.push_back(cardModel)
	
	# Connect last card from the deck
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)

func pickTopCard(who: int) -> CardInteractable:
	var pickedCard: CardInteractable = cards[-1]
	onTopCardPicked(who)
	return pickedCard

func onTopCardPicked(who: int) -> void:
	cards[-1].picked.disconnect(onTopCardPicked)
	var card: CardInteractable = cards.pop_back()
	
	if not cards.is_empty():
		cards[-1].activate()
		cards[-1].picked.connect(onTopCardPicked)
	
	topCardPicked.emit(card, who)

func addOnTop(cardInteractable: CardInteractable) -> void:
	cards[-1].deactivate()
	cards[-1].picked.disconnect(onTopCardPicked)
	
	cards.push_back(cardInteractable)
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)
