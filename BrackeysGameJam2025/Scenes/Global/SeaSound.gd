extends AudioStreamPlayer

const TIME := 4.0
const INSIDE_CUTOFF := 1800.0
const CRACKLES_VOLUME_MIN := -15.0
const CRACKLES_VOLUME_MAX := 0.0

@onready var SeaFilter : AudioEffectFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SeaSounds"), 0)

var t : Tween
func _ready() -> void:
	volume_db = -30.0
	$crackles.volume_db = -40.0
	SeaFilter.cutoff_hz = INSIDE_CUTOFF
	inside()
	playing = true
	$crackles.playing = true


func inside() -> void:
	if t: t.kill()
	
	t = create_tween().set_parallel(true)
	t.tween_property(self, "volume_db", -5.0, TIME)
	t.tween_property($crackles, "volume_db", CRACKLES_VOLUME_MAX, TIME)
	t.tween_property(SeaFilter, "cutoff_hz", INSIDE_CUTOFF, TIME)


func outside() -> void:
	if t: t.kill()
	
	t = create_tween().set_parallel(true)
	t.tween_property(self, "volume_db", 0.0, TIME)
	t.tween_property($crackles, "volume_db", CRACKLES_VOLUME_MIN, TIME)
	t.tween_property(SeaFilter, "cutoff_hz", 20500.0, TIME)
