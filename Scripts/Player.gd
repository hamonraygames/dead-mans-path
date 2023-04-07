extends CharacterBody3D

@onready var gun_controller = $GunController
var SPEED = 5

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

	velocity = direction.normalized() * SPEED	
	move_and_slide()

func shoot():
	if Input.is_action_pressed("primary_action"):
		gun_controller.gun_shoot()

