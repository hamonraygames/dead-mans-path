extends Node3D

var ray_origin = Vector3()
var ray_target = Vector3()

func _physics_process(delta):
	var mouse_position = get_viewport().get_mouse_position()	
	
	ray_origin = $Camera3D.project_ray_origin(mouse_position)
	ray_target = ray_origin + $Camera3D.project_ray_normal(mouse_position) * 2000
	
	var space_state = get_world_3d().direct_space_state
	var parameters = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var intersection = space_state.intersect_ray(parameters)
	
	if not intersection.is_empty():
		var position = intersection.values()[0]
		var look_at_me = Vector3(position.x, $Player.position.y, position.z)
		$Player.look_at(look_at_me)
