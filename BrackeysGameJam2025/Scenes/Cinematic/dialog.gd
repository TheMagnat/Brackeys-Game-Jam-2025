extends CanvasLayer

signal chose(int)
signal finished

@onready var TEST_CHAR := $Characters/TestChar

@onready var DIALOG_TEXT := $Resources/DialogLabel
@onready var DIALOG_BUTTON := $Resources/Button

func write_text(c: DialogCharacter, t: String, angry := false) -> DialogLabel:
	for child in $Text.get_children(): child.queue_free()
	for child in $icon.get_children(): child.queue_free()
	
	var char := c.duplicate()
	var text := DIALOG_TEXT.duplicate()
	
	$Text.add_child(text)
	text.write(t)
	
	$icon.add_child(char)
	char.start_talking(angry)
	text.finished.connect(char.stop)
	
	return text

func choice(c: DialogCharacter, t: String, choices: Array[String], angry := false) -> void:
	var buttons := []
	for i in choices.size():
		buttons.append(DIALOG_BUTTON.duplicate())
		buttons.back().text = choices[i]
		buttons.back().pressed.connect(chose.emit.bind(i))
	
	await write_text(c, t, angry).finished
	
	for btn in buttons:
		await get_tree().create_timer(0.5).timeout
		$Text.add_child(btn)

func write(c: DialogCharacter, t: String, angry := false) -> void:
	await write_text(c, t, angry).finished
	
	finished.emit()

func _ready() -> void:
	choice(TEST_CHAR, "yo do you want to play or die mate", ["play", "die"])
	chose.connect(func(v: int):
		if v == 0:
			write(TEST_CHAR, "ok so for this one I'll make a longer dialog because I want to see how it turns out on the long run")
		else:
			write(TEST_CHAR, "FUCK YOU WHY WOULD YOU EVER WANT TO KILL YOURSELF", true), CONNECT_ONE_SHOT)
