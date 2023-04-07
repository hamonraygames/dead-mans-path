extends Node3D

@export var Bullet: PackedScene
@export var muzzle_speed = 30
@export var millis_between_shots = 100
@onready var rof_timer = $Timer

var equiped_weapon: Node3D
var can_shoot = true
var hand

func _ready():
	rof_timer.wait_time = millis_between_shots / 1000.0

func _process(delta):
	pass

func shoot_bullet():
	if can_shoot:
		var new_bullet = Bullet.instantiate()
		new_bullet.global_transform = $Muzzle.global_transform
		new_bullet.speed = muzzle_speed
		var scene_root = get_tree().get_root().get_children()[0]
		scene_root.add_child(new_bullet)
		can_shoot = false
		rof_timer.start()

func _on_timer_timeout():
	can_shoot = true
	
	
