extends Node


var cardManager: CardManager

var isHandActive: bool = true
var isTryingToHoldCard: bool = true
var mouseRelativeXPos: float = 0.0

## Game Phase
var canInteract: bool = false
var gameFinished: bool = false
var gameTrulyFinished: bool = false
var drawPhase: bool = true

## Game Rules
const GAME_TO_WIN_TO_FINISH: int = 3
const TOTAL_TO_NOT_REACH: int = 10
const MAX_CARDS_IN_HAND: int = 4

## Pirate settings
const ANGRY_DURATION: float = 2.0

var goodEnding: bool = false
var shouldSkipFirstIntro: bool = false

func _ready() -> void:
	get_tree().scene_changed.connect(reset)

func reset() -> void:
	isHandActive = true
	isTryingToHoldCard = true
	mouseRelativeXPos = 0.0
	
	canInteract = false
	gameFinished = false
	gameTrulyFinished = false
	drawPhase = true
	
	CardModel.playerCardTracker.clear()
