extends CanvasLayer

const TIME := 4.0

var labels := []
var parent : VBoxContainer = null

func _ready() -> void:
	hide()

func main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func start(accept: bool) -> void:
	SeaSound.game_ended.connect(main_menu, CONNECT_ONE_SHOT)
	
	$Accept.hide()
	$Refuse.hide()
	$End.modulate.a = 0.0
	
	SeaSound.ending()
	labels = $Accept.get_children() if accept else $Refuse.get_children()
	parent = $Accept if accept else $Refuse
	
	parent.show()
	for lbl in labels:
		lbl.modulate.a = 0.0
	
	
	show()
	tween()


var t : Tween
var current : Label = null
func tween() -> void:
	if labels.is_empty() and current == null:
		return
	
	if t:
		t.kill()
		if current: current.modulate.a = 1.0
	
	t = create_tween()
	if labels.is_empty() and current != null:
		current = null
		t.tween_property(parent, "modulate:a", 0.0, TIME * 2.0)
		t.tween_property($End, "modulate:a", 1.0, TIME)
		t.tween_interval(TIME)
		t.tween_callback(func(): $End/Label.text = "A game by TheMagnat, ObaniGarage and Kryspou")
		t.tween_interval(TIME)
		t.tween_callback(func(): $End/Label.text = "For the Brackeys Game Jam 2025.2")
		t.tween_interval(TIME)
		t.tween_callback(func(): $End/Label.text = "Hope you enjoyed")
		t.tween_property($End, "modulate:a", 0.0, TIME * 4.0)
	else:
		current = labels.pop_front()
		t.tween_property(current, "modulate:a", 1.0, TIME)
		t.tween_callback(tween)
