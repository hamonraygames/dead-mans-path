extends Node

class_name Stats

@export 
var max_hp = 5

var current_hp = max_hp

signal you_died_signal

func take_hit(damage_amount):
	current_hp -= damage_amount
	
	if current_hp <= 0:
		die()
	else:
		print("Hit, ", current_hp)
	
func die():
	emit_signal("you_died_signal")
