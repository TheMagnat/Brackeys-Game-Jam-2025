class_name DistractionManager extends Node3D


@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"
@onready var material: StandardMaterial3D = mesh_instance_3d.material_override

@onready var pirateModel: PirateModel = %PirateModel

var isDistracted: bool = false

var remainingDistractionTime: float = 0.0
func _process(delta: float) -> void:
	if not isDistracted: return
	
	remainingDistractionTime -= delta
	if remainingDistractionTime <= 0.0:
		stopDistraction()

func stopDistraction() -> void:
	isDistracted = false
	remainingDistractionTime = 0.0
	
	pirateModel.showFrontFace()

func getDistracted(pos: Vector3) -> void:
	remainingDistractionTime = 5.0
	isDistracted = true
	
	pirateModel.showSideFace(pos.x < 0.0)

var objectThatAlreadyDistracted: Dictionary[Node3D, int]
func _on_ground_detector_body_entered(body: Node3D) -> void:
	if body in objectThatAlreadyDistracted: return
	
	objectThatAlreadyDistracted[body] = 0
	getDistracted(body.global_position)
