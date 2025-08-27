extends CanvasLayer

func _ready():
	$VBoxContainer/Resume.pressed.connect(hide)
	$VBoxContainer/Quit.pressed.connect(quit)
	$VBoxContainer/Fullscreen.pressed.connect(fullscreen)
	
	check_fullscreen()
	hide()

func check_fullscreen():
	if get_window().mode == Window.MODE_FULLSCREEN:
		$VBoxContainer/Fullscreen.text = "Surface"
	else:
		$VBoxContainer/Fullscreen.text = "Immerse"

func fullscreen() -> void:
	if get_window().mode == Window.MODE_FULLSCREEN:
		get_window().mode = Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_FULLSCREEN
	check_fullscreen()

func quit():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
