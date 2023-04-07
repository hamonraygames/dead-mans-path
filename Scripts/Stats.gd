extends Node

class_name Stats

@export var max_hp = 10
var current_hp = max_hp

signal  you_died_signal
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func take_hit(damage_amount):
	current_hp -= damage_amount
	
	if current_hp <= 0:
		die()
	else:
		print("Hit, ", current_hp)
	
func die():
	emit_signal("you_died_signal")
