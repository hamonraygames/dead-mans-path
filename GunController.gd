extends Node

@export var StartingWeapon: PackedScene
var hand
var equiped_weapon: Node3D

func _ready():
	hand = get_parent().find_child("Hand")
	
	if StartingWeapon:
		equip_weapon(StartingWeapon)
		
func equip_weapon(weapon_to_equip):
	if equiped_weapon:
		equiped_weapon.queue_free()
		print("current weapon deleted")
	else:
		equiped_weapon = weapon_to_equip.instantiate()
		print("weapon equipped")
		hand.add_child(equiped_weapon)
		
