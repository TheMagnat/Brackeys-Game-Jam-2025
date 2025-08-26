extends CanvasLayer

const TIME := 5.0

@onready var labels := $VBoxContainer.get_children()

func _ready() -> void:
	for lbl in labels:
		lbl.modulate.a = 0.0
	
	tween()


var t : Tween
var current : Label = null
func tween() -> void:
	if t:
		t.kill()
		if current: current.modulate.a = 1.0
	
	t = create_tween()
	if labels.is_empty():
		t.tween_property($Line2D, "modulate:a", 0.0, TIME)
		t.parallel().tween_property($VBoxContainer, "modulate:a", 0.0, TIME)
		t.tween_callback(queue_free)
	else:
		current = labels.pop_front()
		t.tween_property(current, "modulate:a", 1.0, TIME)
		t.tween_callback(tween)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SELECT"):
		tween()
