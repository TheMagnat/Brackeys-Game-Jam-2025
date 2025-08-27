class_name Deck extends Node3D

signal topCardPicked(card: CardInteractable, who: int)

var cards: Array[CardInteractable]
var cardsModels: Array[CardModel]

var count: int = 52
const randomRotation: float = PI / 32.0

const CARD_COLLISION_SHAPE: BoxShape3D = preload("uid://bm58nbans4mp1")
const CARD_MODEL = preload("uid://dnqbvrx07oldi")

@onready var cardStep: float = CARD_COLLISION_SHAPE.size.z / 2.0
@onready var startPos: float = cardStep / 2.0

func _ready() -> void:
	var indices: Array[int]
	indices.assign(range(count))
	indices.shuffle()
	
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

func helpDropOnTop(card: CardInteractable) -> void:
	addOnTop(card)
	pass

#const CARD_SHADER = preload("uid://dbsvhn4bmcga1")
#const ALPHA_CARD_SHADER = preload("uid://bu6po0ymbted5")
#const CARD_ALPHA_MATERIAL = preload("uid://dy0hq0brayjv5")

var tween: Tween
func addOnTop(cardInteractable: CardInteractable) -> void:
	cards[-1].deactivate()
	cards[-1].picked.disconnect(onTopCardPicked)
	
	#cardInteractable.deactivate()
	#cardInteractable.model.meshInstance.material_override = CARD_ALPHA_MATERIAL
	#var shaderMaterial: ShaderMaterial = cardInteractable.model.meshInstance.material_override
	#if tween: tween.kill()
	#tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(shaderMaterial, "shader_parameter/hidden", 1.0, 0.75)
	#tween.parallel().tween_property(cardInteractable, "position:y", 20.0, 0.75).as_relative()
	#tween.tween_property(cardInteractable, "global_position", global_position + Vector3.UP * 20.0, 0.0)
	#tween.tween_property(cardInteractable, "rotation", Vector3(PI / 2.0, PI + randf_range(-randomRotation, randomRotation), 0.0), 0.0)
	#tween.tween_callback(cardInteractable.reset_physics_interpolation)
	#tween.tween_property(shaderMaterial, "shader_parameter/hidden", 0.0, 0.75)
	#tween.parallel().tween_property(cardInteractable, "position:y", startPos + (cards.size() + 2) * cardStep, 0.75)
	#tween.tween_callback(func() -> void: cardInteractable.model.meshInstance.material_override = cardInteractable.model.shaderMaterial)
	#tween.tween_callback(func() -> void: _finishAddOnTop(cardInteractable))
	#
#func _finishAddOnTop(cardInteractable: CardInteractable) -> void:
	# Set its position
	#cardInteractable.global_position = global_position + Vector3.UP * 20.0
	#cardInteractable.rotation = Vector3(PI / 2.0, PI + randf_range(-randomRotation, randomRotation), 0.0)
	#cardInteractable.reset_physics_interpolation()
	
	cards.push_back(cardInteractable)
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)

func _physics_process(delta: float) -> void:
	if cards.size() > 1 and not Global.gameFinished:
		cards[-1].global_position.x = lerp(cards[-1].global_position.x, global_position.x, delta * 10.0)
		cards[-1].global_position.z = lerp(cards[-1].global_position.z, global_position.z, delta * 10.0)
		cards[-1].position.y = lerp(cards[-1].position.y, startPos + (cards.size() + 2.0) * cardStep, delta * 10.0)
		
		cards[-1].rotation.x = PI / 2.0
