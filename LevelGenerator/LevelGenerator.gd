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
var obstacle_density = 0.2 : 
	set(value):
		obstacle_density = value
		generate_map()
	get:
		return obstacle_density

@export
var rng_seed: int = 12345: 
	set(value):
		rng_seed = value
		generate_map()
	get:
		return rng_seed
	
@export_range(1, 5)
var obstacle_max_height = 5: 
	set(value):
		obstacle_max_height = max(value, obstacle_min_height)
		generate_map()
	get:
		return obstacle_max_height	
	
@export_range(1, 5)
var obstacle_min_height = 1: 
	set(value):
		obstacle_min_height = min(value, obstacle_max_height)
		generate_map()
	get:
		return obstacle_min_height		

var map_coords_array : Array = []

class Coord:
	var x: int
	var z: int
	
	func _init(x, z):
		self.x = x
		self.z = z
	
	func _to_string():
		return "(" + str(x) + "," + str(z) + ")"
	
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
	
func fill_map_coords_array():
	map_coords_array = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords_array.append(Coord.new(x, z))	

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
	fill_map_coords_array()
#	print(map_coords_array)
	seed(rng_seed)
	map_coords_array.shuffle()
#	print(map_coords_array)
	print("Generating the obstacles...")
	
	var number_of_obstacles: int = map_coords_array.size() * obstacle_density
	if number_of_obstacles > 0:
		for coord in map_coords_array.slice(0, number_of_obstacles):
			create_obstacles_at(coord.x, coord.z)
#	for x in range(map_width):
#		for z in range(map_depth):
#			if randf() < obstacle_density:

func create_obstacles_at(x,z):
	var temp
	var obstacle_position = Vector3(x * 2 - map_width + 1, 0, z * 2 - map_depth + 1)
	var obstacle: CSGBox3D = ObstacleScene.instantiate()
	temp = get_obstacle_height()
	obstacle.height = temp
	obstacle.transform.origin = obstacle_position + \
	Vector3(0, temp / 2 , 0)
	
	print()
	add_child(obstacle)

func get_obstacle_height():
	return randf_range(obstacle_min_height, obstacle_max_height)
