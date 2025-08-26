class_name GameManager extends Node3D

@onready var hand: CardHand = %CardHand
@onready var playerHandManager: PlayerHandManager = %PlayerHandManager

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

const CARD_COLLISION_SHAPE = preload("uid://bm58nbans4mp1")

var currentGameAcc: int = 0

func _ready() -> void:
	hand.cardSelected.connect(onCardSelected)
	EventBus.cardPlayed.connect(onCardPlayed)


const cardValueToTrueValue: Dictionary[CardModel.VALUE, int] = {
	CardModel.VALUE.AS: 1,
	CardModel.VALUE.TWO: 2,
	CardModel.VALUE.THREE: 3,
	CardModel.VALUE.FOUR: 4,
	CardModel.VALUE.FIVE: 5,
	CardModel.VALUE.SIX: 6,
	CardModel.VALUE.SEVEN: 7,
	CardModel.VALUE.EIGHT: 8,
	CardModel.VALUE.NINE: 9,
	CardModel.VALUE.TEN: 10,
	CardModel.VALUE.JACK: -10
}

func computeCardTrueValue(cardModel: CardModel) -> int:
	return cardValueToTrueValue[cardModel.value]

func onCardPlayed(card: CardInteractable) -> void:
	var cardValue: int = computeCardTrueValue(card.model)
	currentGameAcc += cardValue

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
	
	var cardModelGlobalTransform: Transform3D = card.model.global_transform
	
	var handPosition: Vector3
	if result:
		handPosition = result.position
	else:
		handPosition = cardModelGlobalTransform.origin
	
	var newInteractable := CardInteractable.new()
	add_child(newInteractable)
	
	var collisionShape := CollisionShape3D.new()
	collisionShape.shape = CARD_COLLISION_SHAPE
	
	newInteractable.global_transform = cardModelGlobalTransform
	
	newInteractable.add_child(collisionShape)
	newInteractable.initializeModel(card.model) # This method steal the node so we can release the old card after
	
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


func _on_off_table_detector_body_entered(body: Node3D) -> void:
	var card: CardInteractable = body
	
	EventBus.forceStoreCard.emit(card)
