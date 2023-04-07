extends Node3D

@export var speed = 70
const KILL_TIME = 2
var timer = 0

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)
	
	timer += delta
	if KILL_TIME <= timer:
		queue_free()

func _on_area_3d_body_entered(body):
	print("Hit")
	queue_free()
