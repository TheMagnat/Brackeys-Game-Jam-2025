class_name DialogCharacter extends Sprite2D

@export var character_name := "no name"
@export var anim_speed := 0.25
@export var sound_speed_min := 0.125
@export var sound_speed_max := 0.25
@export var stream : AudioStreamRandomizer
@onready var audio := $AudioStreamPlayer

func _ready():
	$AudioStreamPlayer.stream = stream
	$Name.text = character_name

var angry := false
func start_talking(a: bool):
	if hframes > 1 or vframes > 1:
		angry = a
		frame = 1
		talk_visuals()
		talk_voice()
		
		audio.volume_db = -5.0 if angry else -10.0
		audio.pitch_scale = 0.9 if angry else 0.5

func talk_voice():
	if frame == 0:
		return
	
	audio.play()
	get_tree().create_timer(randf_range(sound_speed_min, sound_speed_max) * (0.75 if angry else 1.0)).timeout.connect(talk_voice)

func talk_visuals():
	if frame == 0:
		return
	
	frame = maxi(1, (frame + 1) % (hframes * vframes))
	get_tree().create_timer(anim_speed).timeout.connect(talk_visuals)


func stop():
	frame = 0
