extends CharacterBody3D

@onready var gun_controller = $GunController
@export var speed = 0
@export var max_speed = 20
@export var gravity = 5.0
@export var accel = 1

func _physics_process(delta):
	move()
	shoot()
		
func move():
	var direction = Vector3()
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1 
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1 
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1 
	if Input.is_action_pressed("ui_down"):
		direction.z += 1 
	
	direction = Vector3(direction.x, - gravity, direction.z)
	
	velocity = velocity.move_toward(direction.normalized() * max_speed, accel)
	
	if direction:
		velocity = velocity.move_toward(direction.normalized() * max_speed, accel)
	else:
		velocity = velocity.move_toward(Vector3(), accel)

	move_and_slide()

func shoot():
	if Input.is_action_pressed("primary_action"):
		gun_controller.gun_shoot()

func _on_stats_you_died_signal():
	queue_free()


func _on_void_body_entered(body):
	print("hmmmmmmmmmm")
	queue_free()
