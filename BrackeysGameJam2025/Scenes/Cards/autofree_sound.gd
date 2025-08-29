extends AudioStreamPlayer3D

func _ready():
	play()
	finished.connect(queue_free)
