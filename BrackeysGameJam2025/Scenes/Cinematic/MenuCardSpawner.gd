extends Node3D

var count: int = 52
const CARD_COLLISION_SHAPE: BoxShape3D = preload("uid://bm58nbans4mp1")
const CARD_MODEL = preload("uid://dnqbvrx07oldi")

var cards: Array[CardInteractable]

@onready var socle: StaticBody3D = $"../Socle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var indices: Array[int]
	indices.assign(range(count))
	indices.shuffle()
	
	for i: int in indices.size():
		var card := CardInteractable.new()
		card.activated = false
		
		var collisionShape := CollisionShape3D.new()
		collisionShape.shape = CARD_COLLISION_SHAPE
		
		card.add_child(collisionShape)
		add_child(card)
		
		card.collision_layer = 0
		card.collision_mask = 0
		card.gravity_scale = 0.2
		card.linear_damp = 0.0
		card.angular_damp = 0.0
		
		var cardModel: CardModel = CARD_MODEL.instantiate()
		cardModel.setColorAndValueFromId(indices[i])
		cardModel.cardOwner = 2
		
		card.initializeNewModel(cardModel)
		
		cards.push_back(card)

func reset() -> void:
	didExplode = false
	
	currentIndex = count - 1
	
	cardDropDelay = 0.0
	cardExplodeDelay = INITIAL_EXPLODE_DELAY
	resetDelay = INITIAL_RESET_DELAY

const INITIAL_CARD_DROP_DELAY: float = 0.05
var cardDropDelay: float = 0.0
var currentIndex: int = count - 1

# Explode
var didExplode: bool = false
const INITIAL_EXPLODE_DELAY: float = 5.0
var cardExplodeDelay: float = INITIAL_EXPLODE_DELAY

# Reset
const INITIAL_RESET_DELAY: float = 3.0
var resetDelay: float = INITIAL_RESET_DELAY

func explode() -> void:
	didExplode = true
	
	for cardInteractable: CardInteractable in cards:
		cardInteractable.gravity_scale = 0.1
		cardInteractable.collision_layer = 0
		cardInteractable.collision_mask = 0
		
		Vector3.ZERO.direction_to(cardInteractable.global_position)
		cardInteractable.apply_force(
			Vector3(randf_range(-1.0, 1.0), randf_range(0.5, 1.0), randf_range(-1.0, 1.0)).normalized() * 3000.0, 0.25 * Vector3(randf_range(-1.0, 1.0) * 2.5, randf_range(-1.0, 1.0) * 5.0, randf_range(-1.0, 1.0) * 2.5)
		)
	
	await get_tree().create_timer(1.0).timeout
	for cardInteractable: CardInteractable in cards:
		cardInteractable.gravity_scale = 0.25

func _process(delta: float) -> void:
	if currentIndex < 0:
		
		if didExplode:
			resetDelay -= delta
			if resetDelay <= 0.0:
				reset()
			
			return
		
		cardExplodeDelay -= delta
		
		if cardExplodeDelay <= 0.0:
			explode()
		
		return
	
	cardDropDelay -= delta
	if cardDropDelay <= 0.0:
		cardDropDelay = INITIAL_CARD_DROP_DELAY
		
		var card: CardInteractable = cards[currentIndex]
		card.linear_velocity = Vector3.ZERO
		card.angular_velocity = Vector3.ZERO
		
		card.rotation = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))
		card.position = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * 20.0
		card.reset_physics_interpolation()
		
		card.collision_layer = 1
		card.collision_mask = 1
		card.freeze = false
		card.sleeping = false
		
		var randDirection := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		var randTorque := Vector3(randf_range(-100, 100), randf_range(-100, 100), randf_range(-100, 100))
		card.apply_impulse(randDirection * 10.0)
		card.apply_torque_impulse(randTorque)
		
		currentIndex -= 1
