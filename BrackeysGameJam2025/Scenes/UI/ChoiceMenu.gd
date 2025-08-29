extends CanvasLayer


func _ready() -> void:
	EventBus.pirateAsk.connect(choice)
	
	$HBoxContainer.hide()
	$HBoxContainer.modulate.a = 0.0
	EventBus.choosenChoice.connect(finish_choice)
	
	#choice(["kill", "don't kill", "wtf m8"])

func finish_choice(_i: int) -> void:
	for node in $HBoxContainer.get_children():
		if node is Button:
			node.disabled = true
	
	if t: t.kill()
	
	t = create_tween()
	t.tween_property($HBoxContainer, "modulate:a", 0.0, 1.0)
	t.tween_callback($HBoxContainer.hide)

var t : Tween = null
func choice(choices: Array[String]) -> void:
	for node in $HBoxContainer.get_children():
		if node is Button:
			node.queue_free()
	
	if t: t.kill()
	
	for i in choices.size():
		var btn := $Resources/Button.duplicate()
		btn.text = choices[i]
		btn.pressed.connect(EventBus.choosenChoice.emit.bind(i))
		$HBoxContainer.add_child(btn)
	
	$HBoxContainer.show()
	t = create_tween()
	t.tween_property($HBoxContainer, "modulate:a", 1.0, 1.0)
