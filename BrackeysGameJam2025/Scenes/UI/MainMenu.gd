extends Node2D

const MAIN_SCENE := preload("res://Scenes/Demo/MainSceneDemo.tscn")

func _ready() -> void:
	SeaSound.inside()
	$VBoxContainer/Play.pressed.connect(play)
	$VBoxContainer/Quit.pressed.connect(quit)
	$VBoxContainer/Fullscreen.pressed.connect(fullscreen)
	
	$bg.rotation = 0.01
	check_fullscreen()
	tween()

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

func tween() -> void:
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property($bg, "rotation", -signf($bg.rotation) * randf_range(0.5, 1.0) * 0.05, randf_range(5.0, 15.0))
	t.tween_callback(tween)


func play() -> void:
	get_tree().change_scene_to_packed(MAIN_SCENE)

func quit() -> void:
	get_tree().quit()
