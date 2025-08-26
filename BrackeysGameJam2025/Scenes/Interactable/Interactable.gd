class_name Interactable extends RigidBody3D

signal picked(who: int) # 0 = Player, 1 = Pirate

var activated: bool = true
var isPicked: bool = false

@export var meshInstance: MeshInstance3D
var outlineShader: ShaderMaterial

func _ready() -> void:
	if meshInstance:
		initialize()

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
