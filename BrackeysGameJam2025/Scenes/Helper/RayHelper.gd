extends Node3D


func castAreaRay(origin: Vector3, end: Vector3, mask: int) -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, mask)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	return result

func castMouseRay(mask: int) -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var mousePos: Vector2 = get_viewport().get_mouse_position()
	var origin: Vector3 = get_viewport().get_camera_3d().project_ray_origin(mousePos)
	var direction: Vector3 = get_viewport().get_camera_3d().project_ray_normal(mousePos)
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + direction * 30.0, mask)
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	return result

func castTopRay(groundPosition: Vector3, mask: int) -> Vector3:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(groundPosition + Vector3.UP * 20.0, groundPosition, mask)
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		return result.position
	
	return groundPosition

func getMouseGroundPosition(groundHeight: float) -> Vector3:
	# Get the mouse position in viewport coordinates
	var mousePos: Vector2 = get_viewport().get_mouse_position()
	
	# Create a ray from the camera at the mouse position
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	var rayOrigin: Vector3 = camera.project_ray_origin(mousePos)
	var rayDirection: Vector3 = camera.project_ray_normal(mousePos)
	
	# Calculate where the ray intersects the y = 0 plane
	# Using the formula: origin.y + direction.y * t = 0
	# Solving for t: t = -origin.y / direction.y
	var t: float = (groundHeight - rayOrigin.y) / rayDirection.y
	
	# Get the 3D position at the intersection point
	return rayOrigin + rayDirection * t
