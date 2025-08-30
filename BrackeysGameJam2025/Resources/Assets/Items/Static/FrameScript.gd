@tool
extends StaticBody3D

@onready var frontTexture: MeshInstance3D = $FrontTexture

@export var texture: Texture2D:
	set(value):
		texture = value
		
		if frontTexture:
			(frontTexture.material_override as StandardMaterial3D).albedo_texture = texture

func _ready() -> void:
	if texture:
		(frontTexture.material_override as StandardMaterial3D).albedo_texture = texture
