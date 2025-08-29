extends Node3D

const DEBUG := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEBUG:
		$intro.queue_free()
		SeaSound.outside()
	else:
		$intro.finished.connect(SeaSound.outside)

