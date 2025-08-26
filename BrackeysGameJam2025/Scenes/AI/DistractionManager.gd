class_name DistractionManager extends Node3D


@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"
@onready var material: StandardMaterial3D = mesh_instance_3d.material_override

var isDistracted: bool = false

var remainingDistractionTime: float = 0.0
func _process(delta: float) -> void:
	if not isDistracted: return
	
	remainingDistractionTime -= delta
	if remainingDistractionTime <= 0.0:
		isDistracted = false
		material.albedo_color = Color("fffc4a")

func getDistracted(pos: Vector3) -> void:
	remainingDistractionTime = 2.0
	isDistracted = true
	
	material.albedo_color = Color.RED

var objectThatAlreadyDistracted: Dictionary[Node3D, int]
func _on_ground_detector_body_entered(body: Node3D) -> void:
	if body in objectThatAlreadyDistracted: return
	
	objectThatAlreadyDistracted[body] = 0
	getDistracted(body.global_position)
