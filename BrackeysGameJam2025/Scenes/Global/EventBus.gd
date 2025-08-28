extends Node

signal isHandlingItem(isIt: bool)
signal pickedGroundCard(card: CardInteractable)
signal droppedItem(object: Interactable)
signal storeCard(card: CardInteractable)
signal forceStoreCard(card: CardInteractable)

signal cardSelected
signal cardPlayed(card: CardInteractable, who: int)
signal cardAddedInPlayArea(card: CardInteractable)
signal cardRemovedFromPlayArea(card: CardInteractable, resolved: bool)

signal deckCardInPlayArea(card: CardInteractable)

## Distraction
signal objectHittedGround(object: Interactable)

signal gameFinished(winner: int) # Winner is Player if 0, Pirate if 1
signal cheatFinish
signal resetCurrentGame

## Text
signal pirateTalk(t: String, angry: bool)
