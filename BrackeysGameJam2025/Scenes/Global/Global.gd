extends Node



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
