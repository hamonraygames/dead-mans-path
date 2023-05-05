@tool

extends Node3D

@export
var GroundScene: PackedScene

@export
var ObstacleScene: PackedScene

@export_range(1, 21)
var map_width = 11 : 
	set(value):
		map_width = make_odd(value, map_width)
		generate_map()
	get:
		return map_width

@export_range(1, 15)
var map_depth = 11 : 
	set(value):
		map_depth = make_odd(value, map_depth)
		generate_map()
	get:
		return map_depth

@export_range(0, 1, 0.05)
var obstacle_ratio = 0.2 : 
	set(value):
		obstacle_ratio = value
		generate_map()
	get:
		return obstacle_ratio

func _ready():
	generate_map()
	
func make_odd(new_int, old_int):
	if new_int % 2 == 0:
		if new_int > old_int:
			return new_int + 1
		else:
			return new_int - 1
	else:
		return new_int
	
func generate_map():
	print("Generating the map...")
	
	clear_map()
	add_ground()
	add_obstacles()
	
func clear_map():
	for node in get_children():
		node.queue_free()	
		
func add_ground():
	print("Generating the ground...")
	var ground: CSGBox3D = GroundScene.instantiate()
	
	ground.width = map_width * 2
	ground.depth = map_depth * 2
	
	add_child(ground)

func add_obstacles():
	print("Generating the obstacles...")
	for x in range(map_width):
		for z in range(map_depth):
			if randf() < obstacle_ratio:
				var obstacle_position = Vector3(x * 2 - map_width + 1, 1, z * 2 - map_depth + 1)
				var obstacle: CSGBox3D = ObstacleScene.instantiate()
				obstacle.transform.origin = obstacle_position
				add_child(obstacle)
