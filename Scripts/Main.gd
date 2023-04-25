extends Node3D

var ray_origin = Vector3()
var ray_target = Vector3()

@onready
var player = $Player

@onready
var players_hand = $Player/Body/Hand

func _physics_process(delta):
	if is_instance_valid(player):
		var mouse_position = get_viewport().get_mouse_position()	
		
		ray_origin = $Camera3D.project_ray_origin(mouse_position)
		ray_target = ray_origin + $Camera3D.project_ray_normal(mouse_position) * 2000
		
		var space_state = get_world_3d().direct_space_state
		var parameters = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
		var intersection = space_state.intersect_ray(parameters)
		
		if not intersection.is_empty():
			var position = intersection.values()[0]
			var look_at_me = Vector3(position.x, player.position.y, position.z)
			player.look_at(look_at_me)
			var distance_to_pointer = players_hand.global_transform.origin - look_at_me
			if distance_to_pointer.length() > 3:
				players_hand.look_at(look_at_me, Vector3.UP)
