class_name Interactable extends RigidBody3D

signal picked(who: int) # 0 = Player, 1 = Pirate

var activated: bool = true
var isPicked: bool = false

@export var meshInstance: MeshInstance3D
var outlineShader: ShaderMaterial

@export var hitPlayer: AudioStreamPlayer3D
@export var breakPlayer: AudioStreamPlayer3D

var alreadyBroke: bool = false
func onBodyHit(body: Node) -> void:
	if alreadyBroke: return
	
	var vol: float = minf(3.0, (lastVelocity.length() * 40.0 - 30.0))
	
	if global_position.y < 15.0:
		if not alreadyBroke and breakPlayer:
			breakPlayer.volume_db = vol * 1.5
			breakPlayer.play()
			alreadyBroke = true
			return
		
		alreadyBroke = true
	
	if hitPlayer:
		hitPlayer.volume_db = vol
		hitPlayer.play()

func _ready() -> void:
	collision_layer = 0b1000001
	contact_monitor = true
	max_contacts_reported = 1
	
	body_entered.connect(onBodyHit)
	
	if meshInstance:
		initialize()

func _exit_tree() -> void:
	if is_instance_valid(outlineShader): outlineShader.set_shader_parameter("activated", 0.0)

func initialize() -> void:
	outlineShader = meshInstance.material_override.next_pass

func onHovered() -> void:
	showOutlines()

func onUnhovered() -> void:
	hideOutlines()

var tween: Tween
func showOutlines() -> void:
	if tween: tween.kill()
	
	tween = create_tween()
	tween.tween_property(outlineShader, "shader_parameter/activated", 1.0, 0.25)
	
func hideOutlines() -> void:
	if tween: tween.kill()
	
	tween = create_tween()
	tween.tween_property(outlineShader, "shader_parameter/activated", 0.0, 0.25)

var lastPosition: Vector3
var lastVelocity: Vector3
func _physics_process(_delta: float) -> void:
	if activated:
		lastVelocity = global_position - lastPosition
		lastPosition = global_position
