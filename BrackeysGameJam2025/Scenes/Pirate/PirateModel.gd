@tool
class_name PirateModel extends Node3D

@onready var moustacheGauche: Sprite3D = %MoustacheGauche
@onready var moustacheDroite: Sprite3D = %MoustacheDroite

@onready var headHolder: Node3D = %HeadHolder

@onready var headSide: Sprite3D = %HeadSide
@onready var headFront: Sprite3D = %HeadFront

@onready var angrySprite: Sprite3D = $HeadPosition/AngrySprite

var moustacheTween: Tween
var headTween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Moustaches ##
	moustacheGauche.rotation.z = 0.0
	moustacheDroite.rotation.z = 0.0
	
	moustacheTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	moustacheTween.tween_property(moustacheDroite, "rotation:z", 0.07, 1.0).as_relative()
	moustacheTween.parallel().tween_property(moustacheGauche, "rotation:z", -0.07, 1.0).as_relative()
	
	moustacheTween.tween_property(moustacheDroite, "rotation:z", -0.07, 1.0).as_relative()
	moustacheTween.parallel().tween_property(moustacheGauche, "rotation:z", 0.07, 1.0).as_relative()
	
	## Head ##
	headHolder.position = Vector3.ZERO
	
	headTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	headTween.tween_property(headHolder, "position:y", 0.14, 1.5).as_relative()
	headTween.tween_property(headHolder, "position:y", -0.14, 1.5).as_relative()

const leftOffset: float = 0.75
const rightOffset: float = 2.0
func showSideFace(left: bool) -> void:
	headFront.hide()
	
	headSide.flip_h = left
	headSide.position.x = leftOffset if left else rightOffset
	
	headSide.show()

func showFrontFace() -> void:
	headSide.hide()
	headFront.show()

var angryTween: Tween
func onCheatDetected() -> void:
	angrySprite.show()
	
	if angryTween: angryTween.kill()
	angryTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE * 0.8, Global.ANGRY_DURATION / 2.0)
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE, Global.ANGRY_DURATION / 2.0)
	
	#angryTween.tween_interval(Global.ANGRY_DURATION)
	angryTween.tween_callback(angrySprite.hide)
