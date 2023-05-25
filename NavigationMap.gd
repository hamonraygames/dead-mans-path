extends NavigationRegion3D

class_name NavigationMap

const CELL_SIZE = 2

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


@export var map_width: int
@export var map_depth: int

var map_coords_array : Array = []
var random_map_coords := []
@export var obstacle_map : Array = []
var map_center : Coord

func _ready():
	fill_map_coords_array()
	fill_random_map_coords()
	
	
func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)

func fill_map_coords_array():
	map_coords_array = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords_array.append(Coord.new(x, z))	


func fill_random_map_coords():
	random_map_coords = map_coords_array.duplicate()
	random_map_coords.shuffle()

func get_next_random_map_coord():
	if random_map_coords:
		return random_map_coords.pop_front()
	else:
		fill_random_map_coords()
		return random_map_coords.pop_front()

func is_obstacle(coord: Coord):
	return obstacle_map[coord.x][coord.z]

func get_random_empty_coord():
	while true:
		var coord = get_next_random_map_coord()
		if not is_obstacle(coord):
			return coord

func get_random_empty_vector3():
	return coord_to_vector3(get_random_empty_coord())
	
func coord_to_vector3(coord: Coord):
	var x = (CELL_SIZE * coord.x) - ((map_width - 1) * (CELL_SIZE/2))
	var z = (CELL_SIZE * coord.z) - ((map_width - 1) * (CELL_SIZE/2))
	return Vector3(x, 0, z)


