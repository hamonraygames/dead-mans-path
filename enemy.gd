extends CharacterBody3D

@onready 
var nav: NavigationRegion3D = $"../NavigationRegion3D"

@onready
var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready 
var player: CharacterBody3D = $"../Player"

var path = []
var speed = 2


func _physics_process(delta):
	if not nav_agent.is_target_reached():
		var next_location = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_location)
		global_position += direction * delta * speed 

func set_target_position(target_position):
	nav_agent.target_position = target_position


func _on_timer_timeout():
	set_target_position(player.global_position)
