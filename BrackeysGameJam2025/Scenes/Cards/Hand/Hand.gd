@tool
class_name CardHand extends Node3D

signal cardSelected(index: int)

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

var cards: Array[Card]
var cardsInHand: int

var hidingHand: bool = false

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

const CARD_PACKED_SCENE: PackedScene = preload("uid://da4c2limit5rl")

func _ready() -> void:
	
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
	
	updateCardsPosition()
	
	# Connect Player events
	#player.spellsUpdated.connect(updateHandFromPlayer)
	if not Engine.is_editor_hint():
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
	var popedCard: Card = cards.pop_at(index)
	popedCard.removeFromHand()
	#cardsHolder.remove_child(popedCard)
	
	if index == viewedCard:
		viewedCard = -1
	
	cardsInHand -= 1
	
	for i: int in range(index, cards.size()):
		cards[i].handPosition -= 1
	
	return popedCard

func uninitializeCard(index: int) -> void:
	var card: Card = cards[index]
	
	card.viewed.disconnect(onCardViewed)
	card.deviewed.disconnect(onCardDeviewed)

func initializeCard(index: int) -> void:
	var card: Card = cards[index]
	
	card.handPosition = index
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
func updateCardsPosition() -> void:
	if cardsInHand == 0: return
	
	var handViewedCard: int = viewedCard
	if not Engine.is_editor_hint() and not Global.isHandActive:
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
	
	lastInsertionIndex = 0
	
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
		
		if not Engine.is_editor_hint() and Global.isTryingToHoldCard:
			if sampleOffset < Global.mouseRelativeXPos * curveLength:
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

func _physics_process(delta: float) -> void:
#func _process(delta: float) -> void:
	if moving:
		elapsedTime += delta * 10.0
	
	updateCardsPosition()

#endregion

#region Inputs

func onPlayerSelectCard(newSelectedCard: int) -> void:
	cardSelected.emit(newSelectedCard)

func onHandlingItem(isHandling: bool) -> void:
	hidingHand = isHandling
	for card: Card in cards:
		card.area.input_ray_pickable = not isHandling

func onForceStoreCard(cardInteractable: CardInteractable) -> void:
	storeCard(cardInteractable, cards.size())

func onStoreCard(cardInteractable: CardInteractable) -> void:
	storeCard(cardInteractable, lastInsertionIndex)

func storeCard(cardInteractable: CardInteractable, index: int) -> void:
	var oldTransform: Transform3D = cardInteractable.global_transform
	
	var newCard: Card = CARD_PACKED_SCENE.instantiate()
	#newCard.transform = oldTransform
	
	cardInteractable.model.reparent(newCard, false)
	newCard.model = cardInteractable.model
	
	cardInteractable.queue_free()
	
	addCardInHand(newCard, index)
	
	newCard.global_transform = oldTransform

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SELECT"):
		if viewedCard != -1:
			onPlayerSelectCard(viewedCard)
			get_viewport().set_input_as_handled()
	
	# Keyboard inputs
	if event.is_action_pressed("CARD_SHORTCUT_1"):
		onPlayerSelectCard(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("CARD_SHORTCUT_2"):
		onPlayerSelectCard(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("CARD_SHORTCUT_3"):
		onPlayerSelectCard(2)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("CARD_SHORTCUT_4"):
		onPlayerSelectCard(3)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("CARD_SHORTCUT_5"):
		onPlayerSelectCard(4)
		get_viewport().set_input_as_handled()
	
#endregion
