extends Node3D

@export var speed = 70

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(Vector3.FORWARD * speed * delta)
	
