@tool
class_name CardHand extends Node3D

signal cardAdded(index: int)
signal cardSelected(index: int)

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

var cards: Array[Card]
var cardsInHand: int

var hidingHand: bool = false

@export var isPlayer: bool = true
@export var moving: bool = true

@export_category("Owner")
#@export var player: Player

@export_category("Hand Card Positioning")
@export var minCardRotation: float = 0.06
@export var cardRotationBasedOnDist: float = 0.4
@export var spaceBetweenSelected: float = 0.025
@export var spaceBetweenViewed: float = 0.05

@export var spaceBetweenCards: float = 0.6
@export var tuckPercent: float = 0.0

# Card selection and play logic
var viewedCard: int = -1:
	set(value):
		viewedCard = value

# Animation
@export var noise: FastNoiseLite
var elapsedTime: float = 0.0

# DEBUG
@export_category("Debug")
@export_range(0, 50) var numberOfDebugCards: int = 0

# Cache
@onready var cardsHolder: Node3D = $CardsHolder
@onready var path: Path3D = $Path3D
var curveLength: float
var curveCenterLength: float

# Sprites
@onready var handSprites: Node3D = $HandSprites
@onready var back: Sprite3D = $HandSprites/Back
@onready var front: Sprite3D = $HandSprites/Front

const CARD_PACKED_SCENE: PackedScene = preload("uid://da4c2limit5rl")

func _ready() -> void:
	if not isPlayer:
		handSprites.hide()
	
	# Initialize Hand Curve
	path.curve_changed.connect(initializeCurveData)
	initializeCurveData()
	
	# Populate Hand
	populateHandFromPlayer()
	
	# DEBUG
	#if Debug.DEBUG:
	initDebug()
	
	# Initialize cards
	initializeCards()
	
	updateCardsPosition(0.0)
	
	# Connect Player events
	#player.spellsUpdated.connect(updateHandFromPlayer)
	if not Engine.is_editor_hint() and isPlayer:
		EventBus.isHandlingItem.connect(onHandlingItem)
		EventBus.storeCard.connect(onStoreCard)
		EventBus.forceStoreCard.connect(onForceStoreCard)

#region Initializing Methods

func initializeCurveData() -> void:
	curveLength = path.curve.get_baked_length()
	curveCenterLength = curveLength / 2.0

func populateHandFromPlayer() -> void:
	pass
	#if not player:
		#push_warning("Player is not setted in the Hand.")
		#return
	
	#for spellInstance: SpellInstance in player.spells:
		#cards.push_back(spellInstance.card)
		#cardsHolder.add_child(spellInstance.card)

func addCardInHand(cardToAdd: Card, index: int) -> void:
	cardToAdd.resetState()
	
	cardsInHand += 1
	
	cards.insert(index, cardToAdd)
	
	# If there is at least one child, the card as a sibling
	var cardsCount: int = cardsHolder.get_child_count()
	if cardsCount and index < cardsCount:
		cardsHolder.get_child(index).add_sibling(cardToAdd)
	else:
		cardsHolder.add_child(cardToAdd)
	
	for i: int in range(index, cards.size()):
		cards[i].handPosition += 1
	
	initializeCard(index) # Do it after adding it to hand list
	
# DEBUG
func initDebug() -> void:
	const CARD_MODEL_PACKED_SCENE: PackedScene = preload("uid://dnqbvrx07oldi")
	for i: int in numberOfDebugCards:
		var newDebugCard: Card = CARD_PACKED_SCENE.instantiate()
		var newCardModel: CardModel = CARD_MODEL_PACKED_SCENE.instantiate()
		newCardModel.value = i % 11
		
		newDebugCard.add_child(newCardModel)
		newDebugCard.model = newCardModel
		
		cardsHolder.add_child(newDebugCard)
		cards.push_back(newDebugCard)
#END DEBUG

func popCard(index: int) -> Card:
	uninitializeCard(index)
	
	var popedCard: Card = cards.pop_at(index)
	
	if index == viewedCard:
		viewedCard = -1
	
	cardsInHand -= 1
	
	for i: int in range(index, cards.size()):
		cards[i].handPosition -= 1
	
	return popedCard

func uninitializeCard(index: int) -> void:
	var card: Card = cards[index]
	
	if isPlayer:
		card.viewed.disconnect(onCardViewed)
		card.deviewed.disconnect(onCardDeviewed)

func initializeCard(index: int) -> void:
	var card: Card = cards[index]
	
	card.handPosition = index
	
	if isPlayer:
		card.viewed.connect(onCardViewed)
		card.deviewed.connect(onCardDeviewed)

func initializeCards() -> void:
	for i: int in cards.size():
		initializeCard(i)
	
	cardsInHand = cards.size()

#endregion

#region Events

func onCardViewed(card: Card) -> void:
	viewedCard = card.handPosition

func onCardDeviewed(card: Card) -> void:
	if card.handPosition == viewedCard:
		viewedCard = -1

#endregion

#region Cards Positions Managing

var lastInsertionIndex: int = 0
func updateCardsPosition(delta: float) -> void:
	if cardsInHand == 0:
		var handSpritesPosition := Vector3.ZERO
		if hidingHand and (not Engine.is_editor_hint() and not Global.isTryingToHoldCard):
			handSpritesPosition.y = -6.0
	
		handSprites.position = lerp(handSprites.position, handSpritesPosition, delta * 5.0)
		front.rotation.z = lerp_angle(front.rotation.z, PI / 4.0, delta * 5.0)
		front.position.x = lerp(front.position.x, -4.0, delta * 5.0)
		
		return
	
	else:
		front.rotation.z = lerp_angle(front.rotation.z, 0.0, delta * 5.0)
		front.position.x = lerp(front.position.x, 0.0, delta * 5.0)

	
	var handViewedCard: int = viewedCard
	if not Engine.is_editor_hint() and not Global.isHandActive:
		handViewedCard = -1
	
	if viewedCard >= cards.size():
		printerr("WRONG INDEX")
		handViewedCard = -1
	
	var trueCardStep: float
	var currentCardRotation: float
	if cardsInHand > 1:
		var hypoteticalHandLength: float = (cardsInHand - 1) * spaceBetweenCards
		var surplus: float = max(0.0, hypoteticalHandLength - curveLength)
		var surplusOffset: float = surplus / (cardsInHand - 1.0)
		
		trueCardStep = spaceBetweenCards - surplusOffset
		currentCardRotation = minCardRotation + surplusOffset * cardRotationBasedOnDist

	else:
		trueCardStep = spaceBetweenCards
	
		currentCardRotation = minCardRotation
	
	var totalHandLenght: float = (cardsInHand - 1) * trueCardStep
	if handViewedCard != -1:
		totalHandLenght += 2 * spaceBetweenViewed
	
	var halfHandLenght: float = totalHandLenght / 2.0
	
	var startingLength: float = curveCenterLength - halfHandLenght
	
	# Compute the current mouse offset
	var mouseXOffset: float
	if not Engine.is_editor_hint() and Global.isTryingToHoldCard:
		mouseXOffset = (Global.mouseRelativeXPos * 1.2 - 0.1) * (curveLength)
	
	lastInsertionIndex = 0
	
	
	var handSpritesPosition := Vector3.ZERO
	
	var handIndex: int = 0
	var accOffset: float = 0.0
	for i: int in cards.size():
		var card: Card = cards[i]
		
		var cardOffset: float = trueCardStep * handIndex + accOffset
		
		var isHandViewedCard: bool = false
		
		if Engine.is_editor_hint() or Global.isHandActive:
			if handViewedCard != -1 and i == handViewedCard:
				isHandViewedCard = true
				cardOffset += spaceBetweenViewed
				accOffset += 2 * spaceBetweenViewed
		
		var sampleOffset: float = startingLength + cardOffset
		
		if isPlayer and not Engine.is_editor_hint() and Global.isTryingToHoldCard:
			if sampleOffset < mouseXOffset:
				sampleOffset -= spaceBetweenViewed
				lastInsertionIndex = i + 1
			else:
				sampleOffset += spaceBetweenViewed
		
		
		var newPos: Vector3 = path.curve.sample_baked(sampleOffset)
		var newUpVec: Vector3 = path.curve.sample_baked_up_vector(sampleOffset)
		
		# Left basis rotate the card to not overlap cards, the second one rotate the card to make it follow the curve up vector
		var newCardBasis: Basis
		var scaling: float = 1.0
		if isHandViewedCard:
			newPos.z += 2.0
			newPos.y += 4.0
			handSpritesPosition.x = newPos.x * 0.2
			#scaling = 0.75
		else:
			newCardBasis = Basis(newUpVec, currentCardRotation) * Basis(Vector3.BACK, -Vector2(newUpVec.x, newUpVec.y).angle_to(Vector2.DOWN))
		
		if hidingHand and (not Engine.is_editor_hint() and not Global.isTryingToHoldCard):
			newPos.y -= 6.0
		
		# Random movements
		newPos += Vector3(
			noise.get_noise_2d(elapsedTime + i * 20, elapsedTime + i * 20) * 0.2 - 0.1,
			noise.get_noise_2d(elapsedTime + i * 20, -(elapsedTime + i * 20)) * 0.2 - 0.1,
			(1.0 - tuckPercent) * (noise.get_noise_2d(-(elapsedTime + i * 20), elapsedTime + i * 20) * 0.2 - 0.1)
		)
		
		card.globalMode = false
		card.requestedCardPosition = newPos
		card.requestedCardRotation = newCardBasis.get_euler()
		card.requestedCardScale = Vector3(scaling, scaling, scaling)
		
		handIndex += 1
	
	if hidingHand and (not Engine.is_editor_hint() and not Global.isTryingToHoldCard):
		handSpritesPosition.y = -6.0
	
	handSprites.position = lerp(handSprites.position, handSpritesPosition, delta * 5.0)
	
func _physics_process(delta: float) -> void:
#func _process(delta: float) -> void:
	if moving:
		elapsedTime += delta * 10.0
	
	updateCardsPosition(delta)

#endregion

#region Inputs

func onPlayerSelectCard(newSelectedCard: int) -> void:
	cardSelected.emit(newSelectedCard)

func onHandlingItem(isHandling: bool) -> void:
	hidingHand = isHandling
	for card: Card in cards:
		card.area.input_ray_pickable = not isHandling

func onForceStoreCard(cardInteractable: CardInteractable) -> void:
	storeCard(cardInteractable, 0)

func onStoreCard(cardInteractable: CardInteractable) -> void:
	storeCard(cardInteractable, lastInsertionIndex)

func storeCard(cardInteractable: CardInteractable, index: int) -> void:
	var cardModel: CardModel = cardInteractable.model
	
	var oldTransform: Transform3D = cardInteractable.global_transform
	
	var newCard: Card = CARD_PACKED_SCENE.instantiate()
	#newCard.transform = oldTransform
	
	cardModel.reparent(newCard, false)
	newCard.model = cardModel
	
	cardInteractable.queue_free()
	
	addCardInHand(newCard, index)
	
	newCard.global_transform = oldTransform
	
	cardModel.inHand = true
	cardModel.hand = self
	cardModel.handCard = newCard
	
	cardAdded.emit(index)

func _input(event: InputEvent) -> void:
	if not isPlayer: return
	
	if not Global.canInteract: return
	
	if event.is_action_pressed("SELECT"):
		if viewedCard != -1:
			if viewedCard >= cards.size():
				printerr("WRONG INDEX")
				return
			
			onPlayerSelectCard(viewedCard)
			get_viewport().set_input_as_handled()
	
#endregion
