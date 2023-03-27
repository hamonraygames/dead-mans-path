extends CharacterBody3D


var SPEED = 5

func _physics_process(delta):
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
