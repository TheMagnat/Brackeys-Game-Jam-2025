@tool
class_name CardHand extends Node3D

signal cardSelected(index: int)

@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

var cards: Array[Card]
var cardsInHand: int
var cardsSelected: int

var hidingHand: bool = false

@export var moving: bool = true

@export_category("Owner")
#@export var player: Player

@export_category("Hand Card Positioning")
@export var maxSpaceBetweenCards: float = 0.6
@export var minCardRotation: float = 0.06
@export var cardRotationBasedOnDist: float = 0.4
@export var spaceBetweenSelected: float = 0.025
@export var spaceBetweenViewed: float = 0.05

@export var currentSpaceBetweenCards: float = 0.6
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
@export_range(0, 30) var numberOfDebugCards: int = 0

# Cache
@onready var cardsHolder: Node3D = $CardsHolder
@onready var path: Path3D = $Path3D
var curveLength: float
var curveCenterLength: float

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
	if not Engine.is_editor_hint(): EventBus.isHandlingItem.connect(onHandlingItem)

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

func updateHandFromPlayer(added: bool, index: int) -> void:
	pass
	#if added:
		## Here a spell get added
		#var cardToAdd: Card = player.spells[index].card
		#cardToAdd.resetState()
		#
		#cardsInHand += 1
		#
		#cards.push_back(cardToAdd)
		#
		## If there is at least one child, the card as a sibling
		#var cardsCount: int = cardsHolder.get_child_count()
		#if cardsCount and index < cardsCount:
			#cardsHolder.get_child(index).add_sibling(cardToAdd)
		#else:
			#cardsHolder.add_child(cardToAdd)
		#
		#for i: int in range(index, cards.size()):
			#cards[i].handPosition += 1
		#
		#initializeCard(index) # Do it after adding it to hand list
	#
	#else:
		## Here a spell get deleted
		#var cardToDelete: Card = cards[index]
		#if cardToDelete.inHand:
			#cardsInHand -= 1
		#
		#uninitializeCard(index) # Do it before removing it from hand list
		#
		## This line remove both from the card list and the card Holder
		#cardsHolder.remove_child(cards.pop_at(index) as Card)
		#
		#for i: int in range(index, cards.size()):
			#cards[i].handPosition -= 1
	
# DEBUG
func initDebug() -> void:
	const CARD_PACKED_SCENE: PackedScene = preload("uid://da4c2limit5rl")
	for i: int in numberOfDebugCards:
		var newDebugCard: Card = CARD_PACKED_SCENE.instantiate()
		
		cardsHolder.add_child(newDebugCard)
		cards.push_back(newDebugCard)
#END DEBUG

func popCard(index: int) -> Card:
	var popedCard: Card = cards.pop_at(index)
	popedCard.removeFromHand()
	#cardsHolder.remove_child(popedCard)
	
	if popedCard.selected:
		cardsSelected -= 1
	
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


func updateCardsPosition() -> void:
	var handViewedCard: int = viewedCard
	if (not Engine.is_editor_hint() and not Global.isHandActive) or (viewedCard != -1 and cards[viewedCard].selected):
		handViewedCard = -1
	
	var spaceDiff: float = maxf(0, maxSpaceBetweenCards - currentSpaceBetweenCards)
	var currentCardRotation: float = minCardRotation + spaceDiff * cardRotationBasedOnDist
	
	var trueCardStep: float = currentSpaceBetweenCards
	
	var totalHandLenght: float = (cardsInHand - 1) * trueCardStep
	if handViewedCard != -1:
		totalHandLenght += 2 * spaceBetweenViewed
	
	totalHandLenght += cardsSelected * (2 * spaceBetweenSelected)
	
	var halfHandLenght: float = totalHandLenght / 2.0
	
	var startingLength: float = curveCenterLength - halfHandLenght
	
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
			
			if card.selected:
				cardOffset += spaceBetweenSelected
				accOffset += 2 * spaceBetweenSelected
		
		var sampleOffset: float = startingLength + cardOffset
		
		var newPos: Vector3 = path.curve.sample_baked(sampleOffset)
		var newUpVec: Vector3 = path.curve.sample_baked_up_vector(sampleOffset)
		
		# Left basis rotate the card to not overlap cards, the second one rotate the card to make it follow the curve up vector
		var newCardBasis: Basis
		var scaling: float = 1.0
		if isHandViewedCard:
			newPos.z += 0.2
			newPos.y += 0.2
			#scaling = 0.75
		elif card.selected:
			newPos.z -= 0.2
			newPos.y += 0.2
		else:
			newCardBasis = Basis(newUpVec, currentCardRotation) * Basis(Vector3.BACK, -Vector2(newUpVec.x, newUpVec.y).angle_to(Vector2.DOWN))
		
		if hidingHand:
			newPos.y -= 0.3
		
		# Random movements
		newPos += Vector3(
			noise.get_noise_2d(elapsedTime + i * 20, elapsedTime + i * 20) * 0.05 - 0.025,
			noise.get_noise_2d(elapsedTime + i * 20, -(elapsedTime + i * 20)) * 0.05 - 0.025,
			(1.0 - tuckPercent) * (noise.get_noise_2d(-(elapsedTime + i * 20), elapsedTime + i * 20) * 0.01 - 0.005)
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

#func onPlayerSelectCard(newSelectedCard: int) -> void:
	#var trueNewSelectedCard: Card = cards[newSelectedCard]
	#
	#if trueNewSelectedCard.selected:
		#trueNewSelectedCard.selected = false
		#cardsSelected -= 1
		#return
	#
	#trueNewSelectedCard.selected = true
	#cardsSelected += 1

func onHandlingItem(isHandling: bool) -> void:
	hidingHand = isHandling

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SELECT"):
		if viewedCard != -1:
			onPlayerSelectCard(viewedCard)
			get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("SECONDARY_ACTION") or event.is_action_pressed("CANCEL"):
		for card: Card in cards:
			if card.selected:
				card.selected = false
				cardsSelected -= 1
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
