extends Node3D


const ANIM_SPEED := 0.25
const SOUND_SPEED_MIN := 0.125
const SOUND_SPEED_MAX := 0.25

@onready var label: Label3D = $Text

var talking := false
var angry := false
func _start_talking(a: bool) -> void:
	talking = true
	
	angry = a
	_talk_visuals()
	_talk_voice()
	
	$AudioStreamPlayer3D.volume_db = 6.0 if angry else 0.0
	$AudioStreamPlayer3D.pitch_scale = 0.9 if angry else 0.5

func _stop_talking() -> void:
	talking = false

func _talk_voice() -> void:
	if !talking:
		return
	
	$AudioStreamPlayer3D.play()
	var sceneTree: SceneTree = get_tree()
	if sceneTree:
		sceneTree.create_timer(randf_range(SOUND_SPEED_MIN, SOUND_SPEED_MAX) * (0.75 if angry else 1.0)).timeout.connect(_talk_voice)

# nothing
func _talk_visuals() -> void:
	return
	get_tree().create_timer(ANIM_SPEED).timeout.connect(_talk_visuals)



static func _process_text_length(word: String) -> int:
	var l := 0
	for letter in word:
		l += 15
	return l

const TEXT_SPEED := 0.04
const MAX_TEXT_SIZE := 800.0

var writing := false
var skip := false
var timer : SceneTreeTimer
func _write(t: String) -> void:
	if is_instance_valid(timer):
		for c in timer.timeout.get_connections():
			timer.timeout.disconnect(c.callable)
	
	writing = true
	if skip or t.length() <= 1:
		label.text += t
		writing = false
		EventBus.dialogFinished.emit()
	else:
		var split_by_line : PackedStringArray = label.text.split("\n")
		if t[0] == " " and (_process_text_length(split_by_line[split_by_line.size() - 1] + " " + t.split(" ")[1])) > MAX_TEXT_SIZE:
			t[0] = "\n"
		
		label.text += t[0]
		
		# To prevent crash when closing game
		var sceneTree: SceneTree = get_tree()
		if sceneTree:
			timer = sceneTree.create_timer(TEXT_SPEED)
			timer.timeout.connect(_write.bind(t.right(-1)))
	
	skip = false


func write(t: String, a := false) -> void:
	clear()
	
	_write(t)
	
	_start_talking(a)

func onDialogFinished() -> void:
	_stop_talking()

func clear() -> void:
	label.text = ""
	if is_instance_valid(timer):
		for c in timer.timeout.get_connections():
			timer.timeout.disconnect(c.callable)

func _ready() -> void:
	EventBus.dialogFinished.connect(onDialogFinished)
	
	EventBus.pirateTalk.connect(write)
	EventBus.clearDialog.connect(clear)
	
	clear()
	
	#example
	#await get_tree().create_timer(1.0).timeout
	#write("yo do you want to play or die mate I wanna try a bit like yo wadup what's up dilup didup yo bodup", true)
	#await get_tree().create_timer(6.0).timeout
	#clear()
