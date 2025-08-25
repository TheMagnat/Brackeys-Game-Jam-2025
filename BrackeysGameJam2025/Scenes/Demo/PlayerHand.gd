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

##TEST
@onready var joint: Joint3D = $PinJoint3D

var lastPos: Vector3
var velocity: Vector3
func _physics_process(delta: float) -> void:
	if joint.node_b:
		velocity = (hoveredObject.global_position - lastPos) / delta
		lastPos = hoveredObject.global_position
		global_position.y = lerp(global_position.y, targetY, delta * 3.0)

func hold(toHold: Interactable, handPosition: Vector3) -> void:
	global_position = handPosition
	
	hoveredObject = toHold
	hoverPosition = global_position
	hoverOffset = global_position - RayHelper.getMouseGroundPosition(global_position.y)
	targetY = global_position.y
	
	attach()

func attach() -> void:
	joint.node_b = hoveredObject.get_path()
	EventBus.isHandlingItem.emit(true)

func detach() -> void:
	joint.node_b = NodePath("")
	hoveredObject.apply_central_impulse(velocity * hoveredObject.mass)
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
			if collider is Interactable:
				hoveredObject = collider
				hoverPosition = global_position
				hoverOffset = global_position - RayHelper.getMouseGroundPosition(global_position.y)
				targetY = global_position.y
			else:
				hoveredObject = null
			
		else:
			hoveredObject = null
			global_position = Vector3.ZERO
	
	if event.is_action_pressed("SELECT"):
		if joint.node_b:
			detach()
		elif hoveredObject:
			attach()
	
	if event.is_action_pressed("SCROLL_UP"):
		if joint.node_b:
			targetY += 0.1
	if event.is_action_pressed("SCROLL_DOWN"):
		if joint.node_b:
			targetY -= 0.1
