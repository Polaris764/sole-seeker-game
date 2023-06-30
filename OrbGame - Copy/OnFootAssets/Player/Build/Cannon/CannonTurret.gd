extends Node2D

onready var energy = $Energy
onready var timer = $Energy/Timer
var rng = RandomNumberGenerator.new()

func _on_Timer_timeout():
	var old_frame = energy.frame
	energy.frame = rng.randi()%7
	while energy.frame == old_frame:
		energy.frame = rng.randi()%7
		energy.flip_h = rand_bool()

func rand_bool():
	if rng.randi()%2 == 0:
		return true
	else:
		return false

func add_child(node,_bool_val = false):
	.add_child(node)
	energy.visible = true
	timer.start()
