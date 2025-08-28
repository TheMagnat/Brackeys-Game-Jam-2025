extends Node3D

const DEBUG := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DEBUG:
		$intro.queue_free()
		SeaSound.outside()
	else:
		$intro.finished.connect(SeaSound.outside)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("SECONDARY_ACTION"):
		EventBus.pirateTalk.emit("test comment ça va les loulous", false)
