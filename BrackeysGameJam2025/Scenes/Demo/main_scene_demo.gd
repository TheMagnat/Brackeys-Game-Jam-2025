extends Node3D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@onready var gameManager: GameManager = %GameManager

var soundTween: Tween

func _ready() -> void:
	#animationPlayer.play()
	var bus1: int = AudioServer.get_bus_index("DiceBus")
	var bus2: int = AudioServer.get_bus_index("Interactable")
	
	AudioServer.set_bus_volume_db(bus1, -100.0)
	AudioServer.set_bus_volume_db(bus2, -100.0)
	
	soundTween = create_tween()
	soundTween.tween_method(func(db: float) -> void: AudioServer.set_bus_volume_db(bus1, db), -100.0, 0.0, 1.0)
	soundTween.parallel().tween_method(func(db: float) -> void: AudioServer.set_bus_volume_db(bus2, db), -100.0, 0.0, 1.0)
	
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
