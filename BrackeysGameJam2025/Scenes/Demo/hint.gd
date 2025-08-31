extends Label


func _ready():
	modulate.a = 0.0

var tween : Tween
func hint(t: String) -> void:
	text = t
	
	if tween: tween.kill()
	
	modulate.a = 1.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 10.0)
