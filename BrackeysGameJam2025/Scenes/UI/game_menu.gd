extends CanvasLayer

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	EventBus.introductionStarted.connect(onIntroductionStarted)
	EventBus.introductionFinished.connect(onIntroductionFinished)
	
	$VBoxContainer/Resume.pressed.connect(hide)
	$VBoxContainer/Quit.pressed.connect(quit)
	$VBoxContainer/Fullscreen.pressed.connect(fullscreen)
	$VBoxContainer/Skip.pressed.connect(skip)
	
	check_fullscreen()
	hide()

func check_fullscreen() -> void:
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

func quit() -> void:
	animationPlayer.play_backwards("OpenScene")
	visible = false
	await animationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func skip() -> void:
	EventBus.skipIntroduction.emit()
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !animationPlayer.is_playing():
			visible = !visible
		elif visible:
			visible = false

func onIntroductionStarted() -> void:
	$VBoxContainer/HSeparator3.show()
	$VBoxContainer/Skip.show()

func onIntroductionFinished() -> void:
	$VBoxContainer/HSeparator3.hide()
	$VBoxContainer/Skip.hide()
