extends AnimatedSprite3D

func _ready() -> void:
	wave()

func wave() -> void:
	play("default", randf_range(0.8, 1.25))
	get_tree().create_timer(randf_range(0.5, 8.0)).timeout.connect(wave)
