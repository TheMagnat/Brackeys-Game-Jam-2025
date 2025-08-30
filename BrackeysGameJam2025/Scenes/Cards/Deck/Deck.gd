class_name Deck extends Node3D

signal topCardPicked(card: CardInteractable, who: int)
signal topCardAdded(card: CardInteractable, who: int)

signal shuffleFinished

var cards: Array[CardInteractable]
var cardsModels: Array[CardModel]
@onready var cardHolder: Node3D = $CardHolder

var count: int = 52
const randomRotation: float = PI / 32.0

const CARD_COLLISION_SHAPE: BoxShape3D = preload("uid://bm58nbans4mp1")
const CARD_MODEL = preload("uid://dnqbvrx07oldi")

@onready var cardStep: float = CARD_COLLISION_SHAPE.size.z / 2.0
@onready var startPos: float = cardStep / 2.0

var originalPosition: Vector3

func getShuffleIndices(nbCheats: int) -> Array[int]:
	var indices: Array[int]
	indices.assign(range(count))
	
	var cheatId: Array[int]
	for i: int in nbCheats:
		var queenIndex: int = 51 - i * 13 # Get kings
		indices.pop_at(queenIndex)
		cheatId.push_back(queenIndex)
	
	indices.shuffle()
	var s: int = indices.size()
	for i in cheatId.size():
		var insertionIndex: int = i + 1
		indices.insert(s - insertionIndex, cheatId[i])
	
	return indices

func _ready() -> void:
	originalPosition = global_position
	
	# Generate cards models
	for i: int in count:
		var cardModel: CardModel = CARD_MODEL.instantiate()
		cardModel.setColorAndValueFromId(i)
		cardModel.cardOwner = 2
		
		cardsModels.push_back(cardModel)
	
	var indices: Array[int] = getShuffleIndices(1)
	
	# Generate cards interactable for deck
	for i: int in count:
		var card := CardInteractable.new()
		card.rotation = Vector3(PI / 2.0, PI + randf_range(-randomRotation, randomRotation), 0.0)
		card.position.y = startPos + i * cardStep
		card.activated = false
		card.cardIsHidden = true
		
		var collisionShape := CollisionShape3D.new()
		collisionShape.shape = CARD_COLLISION_SHAPE
		
		card.add_child(collisionShape)
		cardHolder.add_child(card)
		
		card.initializeNewModel(cardsModels[indices[i]])
		
		cards.push_back(card)
	
	# Connect last card from the deck
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)

func pickTopCard(who: int) -> CardInteractable:
	var pickedCard: CardInteractable = cards[-1]
	onTopCardPicked(who)
	return pickedCard

func onTopCardPicked(who: int) -> void:
	cards[-1].picked.disconnect(onTopCardPicked)
	var card: CardInteractable = cards.pop_back()
	
	if not cards.is_empty():
		cards[-1].activate()
		cards[-1].picked.connect(onTopCardPicked)
	
	topCardPicked.emit(card, who)

func helpDropOnTop(card: CardInteractable, who: int) -> void:
	addOnTop(card, who)

#const CARD_SHADER = preload("uid://dbsvhn4bmcga1")
#const ALPHA_CARD_SHADER = preload("uid://bu6po0ymbted5")
#const CARD_ALPHA_MATERIAL = preload("uid://dy0hq0brayjv5")

var tween: Tween
func addOnTop(cardInteractable: CardInteractable, who: int) -> void:
	cards[-1].deactivate()
	cards[-1].picked.disconnect(onTopCardPicked)
	
	cards.push_back(cardInteractable)
	cards[-1].activate()
	cards[-1].picked.connect(onTopCardPicked)
	
	topCardAdded.emit(cardInteractable, who)

var resetingDuration: float = 2.0
func _physics_process(delta: float) -> void:
	if isShuffling: return
	
	if cards.size() > 1 and not Global.gameTrulyFinished:
		if reseting:
			for i: int in cards.size():
				var card: CardInteractable = cards[i]
				
				card.rotation.x = lerp_angle(card.rotation.x, PI / 2.0, delta * 6.0)
				card.rotation.y = lerp_angle(card.rotation.y, resetYRotation[i], delta * 6.0)
				card.rotation.z = lerp_angle(card.rotation.z, 0.0, delta * 6.0)
				
				var resetGoalPosition: Vector3 = global_position
				resetGoalPosition.y += startPos + i * cardStep
				card.global_position = lerp(card.global_position, resetGoalPosition, delta * 6.0)
			
			resetingDuration -= delta
			if resetingDuration <= 0.0:
				# Connect last card from the deck
				cards[-1].activate()
				cards[-1].picked.connect(onTopCardPicked)
				
				resetingDuration = false
				reseting = false
				shuffleFinished.emit()
			
			return
		
		var topCard: CardInteractable = cards[-1]
		
		var goalPosition: Vector3 = global_position
		goalPosition.y += startPos + (cards.size() + 2.0) * cardStep
		topCard.global_position = lerp(topCard.global_position, goalPosition, delta * 10.0)
		
		topCard.rotation.x = lerp_angle(topCard.rotation.x, PI / 2.0, delta * 10.0)
		
const RESET_DURATION: float = 1.5
var reseting: bool = false
var resetYRotation: PackedFloat32Array


func resetCards(includeHand: bool, nbCheats: int, exclude: Array[CardModel]) -> void:
	cards.clear()
	
	resetYRotation = PackedFloat32Array()
	
	var indices: Array[int] = getShuffleIndices(nbCheats) 
	
	for i: int in indices:
		var cardModel: CardModel = cardsModels[i]
		
		if not includeHand and cardModel.inHand: continue
		
		var cardInteractable: CardInteractable = Global.cardManager.getCardInteractableFromModel(cardModel)
		
		if exclude.has(cardModel):
			cardInteractable.sleeping = false
			continue
		
		# Set to deck mode
		cardInteractable.deactivate()
		cardInteractable.cardIsHidden = true
		cardModel.cardOwner = 2
		
		resetYRotation.push_back(PI + randf_range(-randomRotation, randomRotation))
		cards.push_back(cardInteractable)

var isShuffling: bool = false

@onready var shuffleHelperTop: Node3D = $ShuffleHelperTop
@onready var shuffleHelperBot: Node3D = $ShuffleHelperBot
@onready var shufflePath: Path3D = $Path3D

func askShuffle(includeHand: bool, nbCheat: int, exclude: Array[CardModel] = []) -> void:
	Global.canInteract = false
	isShuffling = true
	
	if not cards.is_empty():
		cards[-1].deactivate()
		cards[-1].picked.disconnect(onTopCardPicked)
	
	global_position = Vector3(0.0, 50, -40)
	rotation = Vector3(0.0, PI / 2.0, PI / 4.0)
	
	resetCards(includeHand, nbCheat, exclude)
	
	for card: CardModel in exclude:
		card.cardInteractable.collision_mask = CardInteractable.PHYSICS_LAYER + 0b10
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_callback(func() -> void: for card: CardInteractable in cards: card.reparent(self))
	tween.tween_method(func(t: float) -> void:
		for i: int in cards.size():
			var card: CardInteractable = cards[i]
			
			card.rotation.x = lerp_angle(card.rotation.x, PI / 2.0, 0.016 * 2.0)
			card.rotation.y = lerp_angle(card.rotation.y, resetYRotation[i], 0.016 * 2.0)
			card.rotation.z = lerp_angle(card.rotation.z, 0.0, 0.016 * 2.0)
			
			var resetGoalPosition: Vector3 = global_position
			resetGoalPosition += global_transform.basis.y * (i * cardStep)
			card.global_position = lerp(card.global_position, resetGoalPosition, 0.016 * 2.0)
	, 0.0, 1.0, 2.0)
	
	#if tween: tween.kill()
	#tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(self, "global_position", Vector3(0.0, 50, -40), 1.0)
	#tween.parallel().tween_property(self, "rotation", Vector3(0.0, PI / 2.0, PI / 4.0), 1.0)
	
	await tween.finished
	
	for card: CardModel in exclude:
		card.cardInteractable.collision_mask = CardInteractable.PHYSICS_LAYER + 0b01
	
	var counter: int = 5
	shuffle(counter, nbCheat, exclude)

func shuffle(counter: int, nbCheat: int, exclude: Array[CardModel]) -> void:
	var curveLength: float = shufflePath.curve.get_baked_length()
	
	var length: int = cards.size()
	var middle: int = length / 2
	var offset: int = length / 10
	
	var cut: int = middle + randi_range(-offset, offset)
	
	shuffleHelperTop.position = Vector3.ZERO
	shuffleHelperBot.position = Vector3.ZERO
	
	for i: int in cut:
		cards[i].reparent(shuffleHelperBot)
	
	for i: int in range(cut, cards.size()):
		cards[i].reparent(shuffleHelperTop)
	
	if tween: tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(t: float) -> void:
		shuffleHelperBot.position = shufflePath.curve.sample_baked(t * curveLength), 0.0, 1.0, 0.3)
	tween.parallel().tween_property(shuffleHelperTop, "position:y", shuffleHelperTop.position.y - cut * cardStep, 0.3)
	#tween.tween_property(self, "isShuffling", false, 0.0)
	
	# NOT SURE
	tween.tween_callback(func() -> void: for card: CardInteractable in cards: card.reparent(self))
	#tween.tween_callback(askReset)
	
	tween.tween_method(func(t: float) -> void:
		for i: int in cards.size():
			var card: CardInteractable = cards[i]
			
			card.rotation.x = lerp_angle(card.rotation.x, PI / 2.0, 0.016 * 5.0)
			card.rotation.y = lerp_angle(card.rotation.y, resetYRotation[i], 0.016 * 5.0)
			card.rotation.z = lerp_angle(card.rotation.z, 0.0, 0.016 * 5.0)
			
			var resetGoalPosition: Vector3 = global_position
			resetGoalPosition += global_transform.basis.y * (i * cardStep)
			card.global_position = lerp(card.global_position, resetGoalPosition, 0.016 * 5.0)
	, 0.0, 1.0, 0.1)
	
	await tween.finished
	
	counter -= 1
	if counter > 0:
		shuffle(counter, nbCheat, exclude)
	else:
		finishShuffle(nbCheat, exclude)

func finishShuffle(nbCheat: int, exclude: Array[CardModel]) -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", originalPosition, 1.0)
	tween.parallel().tween_property(self, "rotation", Vector3.ZERO, 1.0)
	
	#for card: CardModel in exclude:
		#card.cardInteractable.activate()
	
	isShuffling = false
	Global.canInteract = true
	
	resetCards(false, nbCheat, exclude)
	
	resetingDuration = RESET_DURATION
	reseting = true
