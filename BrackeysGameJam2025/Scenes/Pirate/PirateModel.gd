@tool
class_name PirateModel extends Node3D

@onready var moustacheGaucheHolder: Node3D = %MoustacheGaucheHolder
@onready var moustacheDroiteHolder: Node3D = %MoustacheDroiteHolder

@onready var moustacheGauche: Sprite3D = %MoustacheGauche
@onready var moustacheDroite: Sprite3D = %MoustacheDroite

@onready var headHolder: Node3D = %HeadHolder
@onready var bodyHolder: Node3D = %BodyHolder

@onready var headSide: Sprite3D = %HeadSide
@onready var headFront: Sprite3D = %HeadFront

@onready var expressionColere: Sprite3D = %ExpressionColere
@onready var expressionTriste: Sprite3D = %ExpressionTriste


@onready var angrySprite: Sprite3D = $HeadPosition/AngrySprite

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var moustacheTween: Tween
var headTween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.startTalkAnimation.connect(talk)
	
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
	bodyHolder.scale = Vector3.ONE
	
	headTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	headTween.tween_property(headHolder, "position:y", 0.14, 1.5).as_relative()
	headTween.parallel().tween_property(bodyHolder, "scale:y", 0.05, 1.5).as_relative()
	headTween.parallel().tween_property(bodyHolder, "scale:x", -0.035, 1.5).as_relative()

	headTween.tween_property(headHolder, "position:y", -0.14, 1.5).as_relative()
	headTween.parallel().tween_property(bodyHolder, "scale:y", -0.05, 1.5).as_relative()
	headTween.parallel().tween_property(bodyHolder, "scale:x", 0.035, 1.5).as_relative()

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

func lookCards() -> void:
	headFront.position = Vector3(0.0, -0.116, 1.446)
	headFront.rotation = Vector3(0.6458, 0.0, 0.0)
	
	sadLook()

func lookPlayer() -> void:
	headFront.position = Vector3.ZERO
	headFront.rotation = Vector3.ZERO
	
	normalLook()

func sadLook() -> void:
	expressionColere.hide()
	expressionTriste.show()

func normalLook() -> void:
	expressionTriste.hide()
	expressionColere.show()

var talkRotation: float = 0.18

var talkOriginalPosition := Vector2(-0.311, -0.318)
var talkAfterPosition := Vector2(-0.075, -0.118)

var talkTween: Tween
func talk(duration: float) -> void:
	if talkTween: talkTween.kill()
	talkTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	var factor: float = duration / 0.25
	
	var inDuration: float = duration * (1.0 / 3.0)
	var outDuration: float = duration * (2.0 / 3.0)
	
	talkTween.tween_property(moustacheGaucheHolder, "position:y", talkAfterPosition.x * factor, inDuration)
	talkTween.parallel().tween_property(moustacheDroiteHolder, "position:y", talkAfterPosition.y * factor, inDuration)
	talkTween.parallel().tween_property(moustacheGaucheHolder, "rotation:z", -talkRotation * factor, inDuration)
	talkTween.parallel().tween_property(moustacheDroiteHolder, "rotation:z", talkRotation * factor, inDuration)

	talkTween.tween_property(moustacheGaucheHolder, "position:y", talkOriginalPosition.x, outDuration)
	talkTween.parallel().tween_property(moustacheDroiteHolder, "position:y", talkOriginalPosition.y, outDuration)
	talkTween.parallel().tween_property(moustacheGaucheHolder, "rotation:z", 0.0, outDuration)
	talkTween.parallel().tween_property(moustacheDroiteHolder, "rotation:z", 0.0, outDuration)

var explodeTween: Tween
func explode() -> void:
	animationPlayer.play("Explode")
	
	angrySprite.show()
	
	if angryTween: angryTween.kill()
	angryTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_loops()
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE * 0.8, Global.ANGRY_DURATION / 2.0)
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE, Global.ANGRY_DURATION / 2.0)

	if explodeTween: explodeTween.kill()
	explodeTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_loops()
	explodeTween.tween_property(self, "position", Vector3.ONE * 0.3, 0.05).as_relative()
	explodeTween.tween_property(self, "position", -Vector3.ONE * 0.3, 0.05).as_relative()

var angryTween: Tween
func onCheatDetected() -> void:
	animationPlayer.play("SortirCrochet")
	onFirstCheatDetected()

func onFirstCheatDetected() -> void:
	angrySprite.show()
	
	if angryTween: angryTween.kill()
	angryTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE * 0.8, Global.ANGRY_DURATION / 2.0)
	angryTween.tween_property(angrySprite, "scale", Vector3.ONE, Global.ANGRY_DURATION / 2.0)
	
	angryTween.tween_callback(angrySprite.hide)
