extends NavigationRegion3D

class_name NavigationMap

func _ready():
	pass

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
@export var obstacle_map : Array = []
var map_center : Coord

func update_map_center():
	map_center = Coord.new(map_width/2, map_depth/2)

func fill_map_coords_array():
	map_coords_array = []
	for x in range(map_width):
		for z in range(map_depth):
			map_coords_array.append(Coord.new(x, z))	
