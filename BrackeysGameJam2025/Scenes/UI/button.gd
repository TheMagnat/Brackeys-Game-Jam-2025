extends Button

func _ready():
	pressed.connect(SeaSound.pressed.play)
