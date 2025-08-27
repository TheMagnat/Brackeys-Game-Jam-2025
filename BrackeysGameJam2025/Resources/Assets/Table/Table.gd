class_name Table extends StaticBody3D


var insideCard: Dictionary[CardInteractable, int]
var notResolvedCard: Dictionary[CardInteractable, int]

func _on_play_area_body_entered(body: Node3D) -> void:
	var card: CardInteractable = body
	insideCard[card] = 0
	notResolvedCard[card] = 0

func _on_play_area_body_exited(body: Node3D) -> void:
	var card: CardInteractable = body 
	var isResolved: bool = true
	
	insideCard.erase(card)
	if card in notResolvedCard:
		notResolvedCard.erase(card)
		isResolved = false
	
	EventBus.cardRemovedFromPlayArea.emit(card, isResolved)

func _physics_process(delta: float) -> void:
	var sleepingCards: Array[CardInteractable]
	for card: CardInteractable in notResolvedCard:
		if card.sleeping:
			sleepingCards.push_back(card)
	
	for card: CardInteractable in sleepingCards:
		notResolvedCard.erase(card)
		if card.cardIsHidden:
			# Its a deck card and its hidden in play area, put it back on deck
			EventBus.deckCardInPlayArea.emit(card)
			return
		
		EventBus.cardAddedInPlayArea.emit(card)
