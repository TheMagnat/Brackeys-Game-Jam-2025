extends Node3D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@onready var gameManager: GameManager = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animationPlayer.play()
	
	if Debug.DEBUG or Global.shouldSkipFirstIntro:
		$intro.queue_free()
		onIntroFinished()
	else:
		$intro.finished.connect(onIntroFinished)

func onIntroFinished() -> void:
	SeaSound.outside()
	
	Global.shouldSkipFirstIntro = true
	
	if Debug.DEBUG:
		animationPlayer.play("OpenScene")
		gameManager.startGame()
		return
	
	await get_tree().create_timer(2.0).timeout
	animationPlayer.play("OpenScene")
	await get_tree().create_timer(3.0).timeout
	
	gameManager.startIntroduction1()
