extends CharacterBody3D

class_name Enemy

@onready 
var nav: NavigationRegion3D = $"../NavigationRegion3D"

@onready
var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready 
var player: CharacterBody3D = $"../Player"

@onready 
var attack_timer = $AttackTimer

var path = []
var speed = 2
var attack_speed_multiplier = 5
var return_position: Vector3
var default_material = load("res://Textures/enemy_default_material.tres")
var rest_material = load("res://Textures/enemy_rest_material.tres")
var attack_material = load("res://Textures/enemy_attack_material.tres")

enum  state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING,
}

var current_state = state.SEEKING

func _physics_process(delta):
	if is_instance_valid(player):
		match current_state:
			state.SEEKING:
				$MeshInstance3D.set_surface_override_material(0, default_material)
				move(delta, speed)
				if $AttackRadius.overlaps_body(player):
					init_attack()
			state.ATTACKING:
				$MeshInstance3D.set_surface_override_material(0, attack_material)
				attacking(delta)
	#			move(delta, speed * attack_speed_multiplier)
			state.RETURNING:
				returning(delta, speed)
				
			state.RESTING:
				$MeshInstance3D.set_surface_override_material(0, rest_material)
				move(Vector3.ZERO)
			
	
func move(delta, final_speed = 1):
	if not nav_agent.is_target_reached():
		var next_location = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_location)
		global_position += direction * delta * final_speed 	
		
	else:
		match current_state:
			state.ATTACKING:
				var player_stats: Stats = player.get_node("Stats")
				player_stats.take_hit(1)
				current_state = state.RETURNING
				returning(delta, speed)
			state.RETURNING:
				current_state = state.RESTING
				attack_timer.start()
				print("timre started")
				
		
func collide_with_other_enemies(should_we_collide):
	pass		
		
func returning(delta, speed):
#	var target_positon: Vector3 = return_position - global_transform.origin
#	var direction: Vector3 = target_positon.normalized()
#	global_position = target_positon
	attack_timer.start()
	current_state = state.RESTING

func attacking(delta):
	return_position = global_transform.origin
	move(delta, speed * attack_speed_multiplier)
		
func set_target_position(target_position):
	nav_agent.target_position = target_position


func _on_stats_you_died_signal():
	queue_free()

func init_attack():
	current_state = state.ATTACKING

func _on_path_update_timer_timeout():
	if is_instance_valid(player):
		set_target_position(player.global_position)


func _on_attack_timer_timeout():
	current_state = state.SEEKING
