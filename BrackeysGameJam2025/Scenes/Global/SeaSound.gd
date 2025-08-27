extends AudioStreamPlayer

const TIME := 4.0
const INSIDE_CUTOFF := 1800.0

const SEA_VOLUME_MIN := -5.0
const SEA_VOLUME_MAX := 0.0
const CRACKLES_VOLUME_MIN := -15.0
const CRACKLES_VOLUME_MAX := 2.0
const HARMONICA_VOLUME_MIN := -30.0
const HARMONICA_VOLUME_MAX := -12.0

@onready var pressed := $pressed
@onready var SeaFilter : AudioEffectFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SeaSounds"), 0)

var t : Tween
func _ready() -> void:
	$HarmonicaLoop.finished.connect(harmonica_timeout)
	
	volume_db = -30.0
	$crackles.volume_db = -40.0
	$HarmonicaLoop.volume_db = -50.0
	SeaFilter.cutoff_hz = INSIDE_CUTOFF
	
	inside()
	harmonica_timeout()
	
	playing = true
	$crackles.playing = true

func harmonica_timeout():
	get_tree().create_timer(randf_range(20.0, 60.0)).timeout.connect(play_harmonica)

func play_harmonica():
	$HarmonicaLoop.play()

func inside() -> void:
	if t: t.kill()
	
	t = create_tween().set_parallel(true)
	t.tween_property(self, "volume_db", SEA_VOLUME_MIN, TIME)
	t.tween_property($crackles, "volume_db", CRACKLES_VOLUME_MAX, TIME)
	t.tween_property($HarmonicaLoop, "volume_db", HARMONICA_VOLUME_MIN, TIME)
	t.tween_property(SeaFilter, "cutoff_hz", INSIDE_CUTOFF, TIME)


func outside() -> void:
	if t: t.kill()
	
	t = create_tween().set_parallel(true)
	t.tween_property(self, "volume_db", SEA_VOLUME_MAX, TIME)
	t.tween_property($crackles, "volume_db", CRACKLES_VOLUME_MIN, TIME)
	t.tween_property($HarmonicaLoop, "volume_db", HARMONICA_VOLUME_MAX, TIME)
	t.tween_property(SeaFilter, "cutoff_hz", 20500.0, TIME)
