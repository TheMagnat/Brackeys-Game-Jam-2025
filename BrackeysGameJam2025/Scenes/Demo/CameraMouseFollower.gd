extends Camera3D


var baseRotation: Vector3
@export var maxRotationOffset := Vector2.ONE * 0.5

func _ready() -> void:
	baseRotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var viewport: Viewport = get_viewport()
	var mouseRatio: Vector2 = viewport.get_mouse_position() / viewport.get_visible_rect().size
	mouseRatio = mouseRatio.clamp(Vector2.ZERO, Vector2.ONE)
	
	mouseRatio = mouseRatio * 2.0 - Vector2.ONE
	
	var currentRotationOffset: Vector2 = maxRotationOffset * mouseRatio
	
	var targetRotation: Vector3 = baseRotation + Vector3(-currentRotationOffset.y, -currentRotationOffset.x, 0.0)
	
	rotation = lerp(rotation, targetRotation, delta * 2.5)
	
