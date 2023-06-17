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
	get:
		return map_width

@export_range(1, 15)
var map_depth = 11 : 
	set(value):
		map_depth = make_odd(value, map_depth)
	get:
		return map_depth

@export_range(0, 1, 0.05)
var obstacle_density = 0.2 : 
	set(value):
		obstacle_density = value
	get:
		return obstacle_density

@export
var rng_seed: int = 12345: 
	set(value):
		rng_seed = value
	get:
		return rng_seed
	
@export
var generate_level: bool = false: 
	set(value):
		generate_map()
	get:
		return generate_level
	
@export
var level_name: String = "New Level"
	
@export
var save_level: bool = false: 
	set(value):
		var packed_scene = PackedScene.new()
		
		for child in level.get_children():
			child.owner = level
		
		packed_scene.pack(level)
		var resource_path =  "res://LevelGenerator/Levels/%s.tscn" % level_name
		ResourceSaver.save(packed_scene, resource_path)
		
		level_name = increment_string(level_name)
		notify_property_list_changed()
	get:
		return generate_level
	
@export
var foreground_color: Color: 
	set(value):
		foreground_color = value
	get:
		return foreground_color
		
@export
var background_color: Color: 
	set(value):
		background_color = value
	get:
		return background_color
		
@export_range(1, 5, 0.25)
var obstacle_max_height: float = 5.0: 
	set(value):
		obstacle_max_height = max(value, obstacle_min_height)
	get:
		return obstacle_max_height	
	
@export_range(1, 5, 0.25)
var obstacle_min_height: float = 1.0: 
	set(value):
		obstacle_min_height = min(value, obstacle_max_height)
	get:   
		return obstacle_min_height		


var level: NavigationMap

func _ready():
	level.update_map_center()
	
 
func increment_string(string):
	var regex = RegEx.new()
	regex.compile("\\d+$")
	var result = regex.search(string)
	var num = result.get_string() if result else "0"
	
	return string.trim_suffix(num) + str(int(num) + 1)

func make_odd(new_int, old_int):
	if new_int % 2 == 0:
		if new_int > old_int:
			return new_int + 1
		else: 
			return new_int - 1
	else:
		return new_int
	
func fill_obstacle_map():
	level.obstacle_map = []
	for x in range(map_width):
		level.obstacle_map.append([])
		for z in range(map_depth):
			level.obstacle_map[x].append(false)

func generate_map():
	print("Generating the map...")
	
	clear_map()
	add_level()
	level.update_map_center()
	add_ground()
	add_obstacles()
	
	rng_seed += 1
	notify_property_list_changed()
	
func clear_map():
	for node in get_children():
		node.free()	

func add_level():
	level = NavigationMap.new()
	level.name = "NavigationRegion3D"
	add_child(level)
	level.owner = self
	
	level.map_depth = map_depth
	level.map_width = map_width
		
	level.navigation_mesh = NavigationMesh.new()
	
	level.bake_navigation_mesh(false)

func add_ground():
	print("Generating the ground...")
	var ground: CSGBox3D = GroundScene.instantiate()
	
	ground.width = map_width * 2
	ground.depth = map_depth * 2
	
	level.add_child(ground)
	ground.owner = self 

func add_obstacles():
	level.fill_map_coords_array()
	fill_obstacle_map()
	
	seed(rng_seed)
	level.map_coords_array.shuffle()
	
	var number_of_obstacles: int = level.map_coords_array.size() * obstacle_density
	var current_obstacle_count = 0
	if number_of_obstacles > 0:
		for coord in level.map_coords_array.slice(0, number_of_obstacles):
			if !level.map_center.check_for_equals(coord):
				
				current_obstacle_count += 1
				level.obstacle_map[coord.x][coord.z] = true
				if map_is_fully_accessable(current_obstacle_count):
					create_obstacles_at(coord.x, coord.z)
				else:
					current_obstacle_count -= 1
					level.obstacle_map[coord.x][coord.z] = false

func map_is_fully_accessable(current_obstacle_count):
	var we_already_checked_here = []
	for x in range(map_width):
		we_already_checked_here.append([])
		for z in range(map_depth):
			we_already_checked_here[x].append(false)
	
	var coords_to_check = [level.map_center]
	we_already_checked_here[level.map_center.x][level.map_center.z] = true
	var accessable_tile_count = 1
	
	while coords_to_check:
		var corrent_tile: NavigationMap.Coord = coords_to_check.pop_front()
		for x in [-1, 0, 1]:
			for z in [-1, 0, 1]:
				if x == 0 or z == 0:
					var neighbor = NavigationMap.Coord.new(corrent_tile.x + x, corrent_tile.z + z)
					if on_the_map(neighbor):
						if not we_already_checked_here[neighbor.x][neighbor.z]:
							if not level.obstacle_map[neighbor.x][neighbor.z]:
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
	
	level.add_child(obstacle)
	obstacle.owner = self 

func get_obstacle_height():
	return randf_range(obstacle_min_height, obstacle_max_height)

func get_color_at_depth(z):
	return background_color.lerp(foreground_color, float(z)/map_depth)
	
	
	
	
	
	
	
	
