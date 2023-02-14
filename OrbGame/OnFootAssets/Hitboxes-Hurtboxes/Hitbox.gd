extends Area2D

signal damage_dealt

export var damage = 1 setget ,dealt_damage
export var knockback_vector = Vector2.ZERO

func dealt_damage():
	emit_signal("damage_dealt")
	return damage
	
# Player Variables
export var harvesting_tool = false

export var harvesting = false

export var harvest_wait_time = 0.0
