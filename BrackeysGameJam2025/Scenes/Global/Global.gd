extends Node



var isHandActive: bool = true
var isTryingToHoldCard: bool = true
var mouseRelativeXPos: float = 0.0

## Game Phase
var canInteract: bool = false
var gameFinished: bool = false
var drawPhase: bool = true

## Game Rules
const TOTAL_TO_NOT_REACH: int = 50
const MAX_CARDS_IN_HAND: int = 4
