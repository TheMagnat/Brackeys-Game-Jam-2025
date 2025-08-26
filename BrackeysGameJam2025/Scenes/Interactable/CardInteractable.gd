class_name CardInteractable extends Interactable

const PHYSICS_LAYER: int = 0b10000000

var cardIsHidden: bool = false

var model: CardModel

func initializeModel(newModel: CardModel) -> void:
	model = newModel
	newModel.reparent(self)
	
	meshInstance = newModel.meshInstance
	initialize()

func initializeNewModel(newModel: CardModel) -> void:
	model = newModel
	add_child(newModel)
	
	meshInstance = newModel.meshInstance
	initialize()

func activate() -> void:
	activated = true
	collision_layer = 0b01 + PHYSICS_LAYER
	freeze = false

func _ready() -> void:
	collision_layer = 0b01
	
	if activated:
		collision_layer += PHYSICS_LAYER
	else:
		freeze = true
	
	mass = 1.0
	linear_damp = 2.0
	angular_damp = 1.0
	continuous_cd = true
