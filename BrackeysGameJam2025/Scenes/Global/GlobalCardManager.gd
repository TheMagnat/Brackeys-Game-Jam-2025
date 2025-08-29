class_name CardManager extends Node3D

var playerHand: PlayerHandManager

const CARD_COLLISION_SHAPE = preload("uid://bm58nbans4mp1")

func _ready() -> void:
	Global.cardManager = self

func convertCardHandToInteractableCard(card: Card) -> CardInteractable:
	var cardModel: CardModel = card.model
	
	var cardModelGlobalTransform: Transform3D = cardModel.global_transform
	
	var newInteractable := CardInteractable.new()
	
	add_child(newInteractable)
	
	var collisionShape := CollisionShape3D.new()
	collisionShape.shape = CARD_COLLISION_SHAPE
	
	newInteractable.global_transform = cardModelGlobalTransform
	
	newInteractable.add_child(collisionShape)
	newInteractable.initializeModel(cardModel) # This method steal the node so we can release the old card after
	
	card.queue_free()
	
	return newInteractable

# Return ready to manage CardInteractable from any CardModel
func getCardInteractableFromModel(cardModel: CardModel) -> CardInteractable:
	if cardModel.inHand:
		var card: Card = cardModel.hand.popCard(cardModel.handCard.handPosition)
		var cardInteractable: CardInteractable = convertCardHandToInteractableCard(card)
		return cardInteractable
	
	else:
		var cardInteractable: CardInteractable = cardModel.cardInteractable
		
		if cardInteractable.isPicked:
			playerHand._detach()
		
		return cardInteractable
