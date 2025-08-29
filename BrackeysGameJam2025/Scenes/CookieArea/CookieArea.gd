extends Node3D

@onready var cookieSprite: Sprite3D = $CookieSprite

var cookieTween: Tween

func _ready() -> void:
	cookieTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	cookieTween.tween_property(cookieSprite, "position:y", 2.0, 4.0).as_relative()
	cookieTween.tween_property(cookieSprite, "position:y", -2.0, 4.0).as_relative()
