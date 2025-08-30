extends Node3D

static func _process_text_length(word: String) -> int:
	var l := 0
	for letter in word:
		l += 15
	return l


const SPEED_MIN := 0.1
const SPEED_MAX := 0.3
const MAX_TEXT_SIZE := 800.0


@onready var label: Label3D = $Text

var talking := false
var angry := false
func _start_talking(t: String, a: bool) -> void:
	talking = true
	
	angry = a
	_talk(t)
	
	$AudioStreamPlayer3D.volume_db = 6.0 if angry else 0.0
	$AudioStreamPlayer3D.pitch_scale = 0.9 if angry else 0.5

func _stop_talking():
	talking = false
	EventBus.dialogFinished.emit()

var timer : SceneTreeTimer
func _talk(t: String) -> void:
	if !talking:
		return
	
	var duration: float = randf_range(SPEED_MIN, SPEED_MAX) * (0.75 if angry else 1.0)
	EventBus.startTalkAnimation.emit(duration)
	
	$AudioStreamPlayer3D.play()
	
	if t.length() <= 1:
		label.text += t
		_stop_talking()
	else:
		var split_by_line : PackedStringArray = label.text.split("\n")
		var last_word := t.split(" ")[0]
		if (_process_text_length(split_by_line[split_by_line.size() - 1] + " " + last_word)) > MAX_TEXT_SIZE:
			label.text += "\n"
		
		label.text += last_word
		
		if last_word.ends_with(","):
			duration *= 2.5
		elif last_word.ends_with(".") or last_word.ends_with("!") or last_word.ends_with("?") or last_word.ends_with("\n"):
			duration *= 5.0
		
		var next_text := t.right(-last_word.length() - 1)
		var sceneTree: SceneTree = get_tree()
		if next_text.strip_edges() != "" and sceneTree:
			label.text += " "
			timer = sceneTree.create_timer(duration)
			timer.timeout.connect(_talk.bind(t.right(-last_word.length() - 1)))
		else:
			_stop_talking()

func write(t: String, a := false) -> void:
	clear()
	
	_start_talking(t, a)

func clear() -> void:
	if is_instance_valid(timer):
		for c in timer.timeout.get_connections():
			timer.timeout.disconnect(c.callable)
	talking = false
	label.text = ""

func _ready() -> void:
	EventBus.pirateTalk.connect(write)
	EventBus.clearDialog.connect(clear)
	
	clear()
	
	#example
	#await get_tree().create_timer(1.0).timeout
	#write("yo do you want to play or die mate I wanna try a bit like yo wadup what's up dilup didup yo bodup", true)
	#await get_tree().create_timer(6.0).timeout
	#clear()
