class_name PlayerHandManager extends Node3D


var hoveredObject: Interactable = null:
	set(value):
		if hoveredObject == value: return
		
		if hoveredObject:
			hoveredObject.onUnhovered()
		
		hoveredObject = value
		if hoveredObject:
			hoveredObject.onHovered()

var targetY: float
var hoverPosition: Vector3
var hoverOffset: Vector3

# Cache to impulse
var requestDetach: bool = false

##TEST
@onready var joint: Joint3D = $PinJoint3D

var lastPos: Vector3
var velocity: Vector3
func _physics_process(delta: float) -> void:
	if requestDetach:
		_detach()
		hoveredObject.apply_central_impulse(velocity * hoveredObject.mass)
		requestDetach = false
	
	Global.isTryingToHoldCard = false
	if joint.node_b:
		velocity = (hoveredObject.global_position - lastPos) / delta
		lastPos = hoveredObject.global_position
		global_position.y = lerp(global_position.y, targetY, delta * 3.0)
		
		if hoveredObject is CardInteractable:
			var viewport: Viewport = get_viewport()
			var mouseRatio: Vector2 = viewport.get_mouse_position() / viewport.get_visible_rect().size
			if mouseRatio.y > 0.75:
				Global.isTryingToHoldCard = true
				Global.mouseRelativeXPos = mouseRatio.x
	
func hold(toHold: Interactable, handPosition: Vector3) -> void:
	global_position = handPosition
	
	hoveredObject = toHold
	hoverPosition = global_position
	hoverOffset = global_position - RayHelper.getMouseGroundPosition(global_position.y)
	targetY = global_position.y
	
	attach()

func attach() -> void:
	hoveredObject.onUnhovered()
	hoveredObject.can_sleep = false
	joint.node_b = hoveredObject.get_path()
	
	hoveredObject.picked.emit()
	EventBus.isHandlingItem.emit(true)

func detach() -> void:
	if Global.isTryingToHoldCard:
		_detach()
		EventBus.storeCard.emit(hoveredObject)
	
	else:
		requestDetach = true

func _detach() -> void:
	hoveredObject.can_sleep = true
	joint.node_b = NodePath("")
	EventBus.isHandlingItem.emit(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if joint.node_b:
			var pos: Vector3 = RayHelper.getMouseGroundPosition(hoverPosition.y) + hoverOffset
			pos.y = global_position.y
			global_position = pos
			return
		
		var result: Dictionary = RayHelper.castMouseRay(0b11)
		if result:
			global_position = result.position# + Vector3.UP * 0.25
			
			var collider: CollisionObject3D = result.collider
			if collider is Interactable and (collider as Interactable).activated:
				hoveredObject = collider
				hoverPosition = global_position
				hoverOffset = global_position - RayHelper.getMouseGroundPosition(global_position.y)
				targetY = global_position.y
			else:
				hoveredObject = null
			
		else:
			hoveredObject = null
			global_position = Vector3.ZERO
	
	if requestDetach: return
	
	if event.is_action_pressed("SELECT"):
		if joint.node_b:
			detach()
		elif hoveredObject:
			attach()
	
	if event.is_action_pressed("SCROLL_UP"):
		if joint.node_b:
			targetY += 2.0
	if event.is_action_pressed("SCROLL_DOWN"):
		if joint.node_b:
			targetY -= 2.0
