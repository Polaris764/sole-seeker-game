extends Node2D

export var wander_range := 32

onready var start_position = global_position
onready var target_position = global_position

onready var timer = $Timer

var rng
export var wander_seed : int = 0

func _ready():
	rng = RandomNumberGenerator.new()
	if wander_seed == 0:
		rng.randomize()
	else:
		rng.seed = wander_seed
	update_target_position()

func update_target_position():
	var target_vector = Vector2(rng.randf_range(-wander_range,wander_range),rng.randf_range(-wander_range,wander_range))
	target_position = start_position+target_vector

func get_time_left():
	return timer.time_left

func _on_Timer_timeout():
	update_target_position()

func start_wander_timer(duration):
	timer.start(duration)
