extends Node3D

@onready var hand: CardHand = %CardHand
@onready var playerHandManager: PlayerHandManager = %PlayerHandManager

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

const CARD_COLLISION_SHAPE = preload("uid://bm58nbans4mp1")

func _ready() -> void:
	hand.cardSelected.connect(onCardSelected)

func onCardSelected(index: int) -> void:
	##TODO: Create ray helper for this instead of doing it here
	# Get mouse position in screen coordinates
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	# Create a ray from the camera through the mouse position
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 100.0  # Ray length
	
	var card: Card = hand.popCard(index)
	var result: Dictionary = RayHelper.castAreaRay(from, to, 0b10000000)
	
	var handPosition: Vector3
	if result:
		handPosition = result.position
	else:
		handPosition = card.holder.global_position
	
	var newInteractable := Interactable.new()
	add_child(newInteractable)
	
	var collisionShape := CollisionShape3D.new()
	collisionShape.shape = CARD_COLLISION_SHAPE
	
	newInteractable.global_transform = card.holder.global_transform
	
	newInteractable.add_child(collisionShape)
	card.holder.reparent(newInteractable)
	
	newInteractable.meshInstance = newInteractable.get_node("Holder/Card/MeshInstance3D")
	newInteractable.initialize()
	
	card.queue_free()
	
	playerHandManager.hold(newInteractable, handPosition)

#func onPlayHand() -> void:
	#Global.isHandActive = false
	#
	#var playedCards: Array[Card]
	#
	#for i: int in range(hand.cards.size() - 1, -1, -1):
		#if hand.cards[i].selected:
			#playedCards.push_back(hand.popCard(i))
	#
	#hand.animationPlayer.play("TuckHand")
	#await hand.animationPlayer.animation_finished
	#animationPlayer.play("SetHandDown")
