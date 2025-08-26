class_name DialogLabel extends Label

static func process_text_length(word: String) -> int:
	var l := 0
	for letter in word:
		l += 15
	return l

signal finished

@export var speed := 0.04

var writing := false
var skip := false
var timer : SceneTreeTimer
func write(t: String):
	if is_instance_valid(timer):
		for c in timer.timeout.get_connections():
			timer.timeout.disconnect(c.callable)
	
	writing = true
	if skip or t.length() <= 1:
		text += t
		writing = false
		finished.emit()
	else:
		var split_by_line := text.split("\n")
		if t[0] == " " and (process_text_length(split_by_line[split_by_line.size() - 1] + " " + t.split(" ")[1])) > size.x:
			t[0] = "\n"
		
		text += t[0]
		timer = get_tree().create_timer(speed)
		timer.timeout.connect(write.bind(t.right(-1)))
	
	skip = false
