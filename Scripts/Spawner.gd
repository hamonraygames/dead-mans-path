extends Node3D


@export var Enemy: PackedScene
@onready var timer = $Timer
@onready var navmap = $"../NavigationRegion3D"

var enemies_remaining_to_spawn: int
var enemies_killed_this_wave: int = 0

var waves
var current_wave: Wave
var current_wave_number = -1

func _ready():
	waves = $Waves.get_children()
	start_next_wave()
	
func start_next_wave():
	enemies_killed_this_wave = 0
	current_wave_number += 1
	if current_wave_number < waves.size():
		current_wave = waves[current_wave_number]
		enemies_remaining_to_spawn = current_wave.num_enemies
		timer.wait_time = current_wave.seconds_between_spawns
		timer.start()


func connect_to_enemy_signals(enemy: Enemy):
	var stats: Stats = enemy.get_node("Stats")
	
	stats.connect("you_died_signal", _on_Enemy_Stats_you_died_signal)
	
func _on_Enemy_Stats_you_died_signal():
	enemies_killed_this_wave += 1

func _on_timer_timeout():
	if enemies_remaining_to_spawn != 0:
		var enemy = Enemy.instantiate()
		
		var location: Vector3 = navmap.get_random_empty_vector3()
		enemy.translate(Vector3(location.x, 0, location.z))
		
		connect_to_enemy_signals(enemy)
		
		var scene_root = get_parent()
		scene_root.add_child(enemy)
		
		enemies_remaining_to_spawn -= 1
	else:
		if enemies_killed_this_wave == current_wave.num_enemies:
			start_next_wave()
