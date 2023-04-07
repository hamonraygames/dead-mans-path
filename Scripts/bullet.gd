extends Node3D

@export var speed = 70
@export var damage = 1
const KILL_TIME = 2
var timer = 0

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)
	
	timer += delta
	if KILL_TIME <= timer:
		queue_free()

func _on_area_3d_body_entered(body: Node):
	
	if body.has_node("Stats"):
		var stats_node = body.find_child("Stats") as Stats
		stats_node.take_hit(damage)
		
	queue_free()
	
