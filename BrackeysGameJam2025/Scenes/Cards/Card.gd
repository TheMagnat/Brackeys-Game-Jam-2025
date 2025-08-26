@tool
class_name Card extends Node3D

const PHYSICS_LAYER: int = 0b100000000

signal viewed(card: Card)
signal deviewed(card: Card)

signal resolved(card: Card)
func emitResolved() -> void: resolved.emit(self)

var mouseInside: bool = false

## Hand related
var handPosition: int

## Position related
# Global Card
var globalMode: bool = false
var requestedCardPosition := Vector3.ZERO
var requestedCardRotation := Vector3.ZERO
var requestedCardScale := Vector3(0.5, 0.5, 0.5)

# Holder
var requestedHolderPosition := Vector3.ZERO
var requestedHolderRotation := Vector3.ZERO

# Cache
@export var model: CardModel

# UI Cache
#@onready var cardName: Label3D = $Holder/Face/Name
#@onready var cardImage: MeshInstance3D = $Holder/Face/Image
#@onready var cardDescription: Label3D = $Holder/Face/Description


func _ready() -> void:
	initializeUi()

func resetState() -> void:
	mouseInside = false
	globalMode = false
	top_level = false

#region UI Settings

func initializeUi() -> void:
	#cardName.text = "TEST_NAME"
	pass

#endregion

func _on_area_3d_mouse_entered() -> void:
	mouseInside = true
	viewed.emit(self)

func _on_area_3d_mouse_exited() -> void:
	mouseInside = false
	deviewed.emit(self)
	requestedHolderRotation = Vector3.ZERO

#func removeFromHand() -> void:
	#area.monitorable = false

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() and Global.isHandActive:
		if mouseInside:
			var mousePositionOnCard: Vector3 = getMousePositionInArea()
			requestedHolderRotation = Vector3(-mousePositionOnCard.y * 0.3, mousePositionOnCard.x * 0.3, 0.0)
	else:
		requestedHolderRotation = Vector3.ZERO

#TODO: Only for debug fluidity, let it in physics_process for real game
#func _process(delta: float) -> void:
	if globalMode:
		global_position = lerp(global_position, requestedCardPosition, 5.0 * delta)
	else:
		position = lerp(position, requestedCardPosition, 5.0 * delta)
	
	rotation = lerp(rotation, requestedCardRotation, 5.0 * delta)
	scale = lerp(scale, requestedCardScale, 5.0 * delta)
	
	model.position = lerp(model.position, requestedHolderPosition, 5.0 * delta)
	model.rotation = lerp(model.rotation, requestedHolderRotation, 5.0 * delta)

# Collision Cache
@onready var area: Area3D = $Area3D
@onready var collisionShape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var shape: BoxShape3D = collisionShape.shape

#region Helper

func getMousePositionInArea() -> Vector3:
	# Get mouse position in screen coordinates
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	# Create a ray from the camera through the mouse position
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 100.0  # Ray length
	
	var result: Dictionary = RayHelper.castAreaRay(from, to, PHYSICS_LAYER)
	if result and result.collider == area:
		return to_local(result.position as Vector3) / shape.size * 2.0
	
	return Vector3.ZERO

#endregion
