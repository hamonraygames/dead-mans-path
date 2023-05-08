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
		update_map_center()
		generate_map()
	get:
		return map_width

@export_range(1, 15)
var map_depth = 11 : 
	set(value):
		map_depth = make_odd(value, map_depth)
		update_map_center()
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
	
@export
var foreground_color: Color: 
	set(value):
		foreground_color = value
		generate_map()
	get:
		return foreground_color
		
@export
var background_color: Color: 
	set(value):
		background_color = value
		generate_map()
	get:
		return background_color
		
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

class Coord:
	var x: int
	var z: int
	
	func _init(x, z):
		self.x = x
		self.z = z
	
	func _to_string():
		return "(" + str(x) + "," + str(z) + ")"
	
	func check_for_equals(coord):
		return self.x == coord.x and self.z == coord.z
	
var map_coords_array : Array = []
var obstacle_map : Array = []
var map_center := Coord.new(map_width/2, map_depth/2)


func _ready():
	update_map_center()
	generate_map()

func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)
	
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

func fill_obstacle_map():
	obstacle_map = []
	for x in range(map_width):
		obstacle_map.append([])
		for z in range(map_depth):
			obstacle_map[x].append(false)

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
	fill_obstacle_map()
	
	seed(rng_seed)
	map_coords_array.shuffle()
	
	var number_of_obstacles: int = map_coords_array.size() * obstacle_density
	var current_obstacle_count = 0
	if number_of_obstacles > 0:
		for coord in map_coords_array.slice(0, number_of_obstacles):
			if !map_center.check_for_equals(coord):
				
				current_obstacle_count += 1
				obstacle_map[coord.x][coord.z] = true
				if map_is_fully_accessable(current_obstacle_count):
					create_obstacles_at(coord.x, coord.z)
				else:
					current_obstacle_count -= 1
					obstacle_map[coord.x][coord.z] = false

func map_is_fully_accessable(current_obstacle_count):
	var we_already_checked_here = []
	for x in range(map_width):
		we_already_checked_here.append([])
		for z in range(map_depth):
			we_already_checked_here[x].append(false)
	
	var coords_to_check = [map_center]
	we_already_checked_here[map_center.x][map_center.z] = true
	var accessable_tile_count = 1
	
	while coords_to_check:
		var corrent_tile: Coord = coords_to_check.pop_front()
		for x in [-1, 0, 1]:
			for z in [-1, 0, 1]:
				if x == 0 or z == 0:
					var neighbor = Coord.new(corrent_tile.x + x, corrent_tile.z + z)
					if on_the_map(neighbor):
						if not we_already_checked_here[neighbor.x][neighbor.z]:
							if not obstacle_map[neighbor.x][neighbor.z]:
								we_already_checked_here[neighbor.x][neighbor.z] = true
								coords_to_check.append(neighbor)
								accessable_tile_count += 1
								
	var target_accessable_tile_count = (map_depth * map_width) - current_obstacle_count
	
	return true if target_accessable_tile_count == accessable_tile_count else false
#	if target_accessable_tile_count == accessable_tile_count:
#		return true
#	else:
#		return false
	
func on_the_map(neighbor):
	return neighbor.x >= 0 and neighbor.x < map_width and neighbor.z >= 0 and neighbor.z < map_depth	
		
func create_obstacles_at(x,z):
	var temp
	var obstacle_position = Vector3(x * 2 - map_width + 1, 0, z * 2 - map_depth + 1)
	var obstacle: CSGBox3D = ObstacleScene.instantiate()
	
	temp = get_obstacle_height()
	obstacle.height = temp
	obstacle.transform.origin = obstacle_position + Vector3(0, temp / 2 , 0)
	
	var new_material := StandardMaterial3D.new()
	new_material.albedo_color = get_color_at_depth(z)
	obstacle.material = new_material
	
	add_child(obstacle)

func get_obstacle_height():
	return randf_range(obstacle_min_height, obstacle_max_height)

func get_color_at_depth(z):
	return background_color.lerp(foreground_color, float(z)/map_depth)
	
	
	
	
	
	
	
	
