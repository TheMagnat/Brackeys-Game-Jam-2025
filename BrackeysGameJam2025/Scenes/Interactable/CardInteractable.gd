class_name CardInteractable extends Interactable

const hit_sound := preload("res://Scenes/Cards/hit_sound.tscn")
const pick_sound := preload("res://Scenes/Cards/pick_sound.tscn")

const PHYSICS_LAYER: int = 0b10000000

var cardIsHidden: bool = false

var model: CardModel

func initializeModel(newModel: CardModel) -> void:
	model = newModel
	newModel.reparent(self)
	
	newModel.inHand = false
	newModel.cardInteractable = self
	
	meshInstance = newModel.meshInstance
	initialize()

func initializeNewModel(newModel: CardModel) -> void:
	model = newModel
	add_child(newModel)
	
	newModel.inHand = false
	newModel.cardInteractable = self
	
	meshInstance = newModel.meshInstance
	initialize()

func activate() -> void:
	activated = true
	collision_layer = 0b01 + PHYSICS_LAYER
	freeze = false
	# Put back to get the hit sound
	#contact_monitor = true
	#max_contacts_reported = 1
	
	lastPosition = global_position

func deactivate() -> void:
	activated = false
	collision_layer = 0b01
	freeze = true
	contact_monitor = false
	max_contacts_reported = 0

@onready var hit: AudioStreamPlayer3D = hit_sound.instantiate()
@onready var pick: AudioStreamPlayer3D = pick_sound.instantiate()

# kinda works
func body_hit(_body: Node3D) -> void:
	hit.volume_db = minf(3.0, (lastVelocity.length() * 40.0 - 30.0))
	hit.play()

func picked_card(_i: int) -> void:
	pick.play()

func _ready() -> void:
	add_child(hit)
	add_child(pick)
	picked.connect(picked_card)
	
	body_entered.connect(body_hit)
	
	collision_layer = 0b01
	
	if activated:
		activate()
	else:
		deactivate()
	
	mass = 1.0
	linear_damp = 2.0
	angular_damp = 1.0
	continuous_cd = true

var lastPosition: Vector3
var lastVelocity: Vector3
func _physics_process(_delta: float) -> void:
	if activated:
		lastVelocity = global_position - lastPosition
		lastPosition = global_position


## Helper
func isOnGround() -> bool:
	if global_position.y < 20.0:
		return true
	
	return false

# Separate method even if it only call isOnGround now, if we want to add things
func isVisible() -> bool:
	print(global_position.y)
	return not isOnGround()
