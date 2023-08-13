extends KinematicBody2D

export (bool) var functional = true
export (int) var speed = 500
export (float) var rotation_speed = 1.5
export (float) var friction = 0.65
export (int) var travel_distance = 500
var max_speed_in_lightyears = 1363
var max_speed_in_lightseconds = 2430
var max_speed_unit
export (int) var travel_distance_squared = 250000
onready var speed_overlay = $FlightUIOverlay/Holder/VBoxContainer/SpeedLabel
onready var overlay = $FlightUIOverlay
onready var shipAudio = $shipAudio
enum location {
	Galaxy,
	System,
	None
}
export (location) var ship_speed = location.None

var velocity = Vector2()
var rotation_dir = 0
var acc = Vector2()
var current_speed_var = 500
onready var speed_particles = $Particles2D
onready var jet_particles = $JetEffect

var turn_divisor : int
func _ready():
	if GalaxySave.game_data["gameModifications"]["speedDemon"]:
		speed *= 4
	if functional:
		overlay.visible = true
	if ship_speed == location.Galaxy:
		turn_divisor = 70
		max_speed_unit = max_speed_in_lightyears
	else:
		turn_divisor = 140
		max_speed_unit = max_speed_in_lightseconds

func _physics_process(delta):
	if functional:
		overlay.visible = true
		rotation_dir = 0
		if Input.is_action_pressed('move_right'):
			rotation_dir += 1
		if Input.is_action_pressed('move_left'):
			rotation_dir -= 1
		if Input.is_action_pressed("move_forward"):
			acc = Vector2(0, -current_speed_var).rotated(rotation)
		elif Input.is_action_pressed("move_backward"):
			acc = Vector2(0, current_speed_var).rotated(rotation)
		else:
			acc = Vector2(0, 0)



		velocity += acc * delta
		current_speed_var = clamp(velocity.length() + 50,0,speed)
		shipAudio.pitch_scale = current_speed_var/500
		rotation += rotation_dir * rotation_speed * delta
		speed_particles.process_material.angle = -rotation_degrees

		var _movement = move_and_slide(velocity, Vector2(0, 0))
		if position.length_squared() > travel_distance_squared:
			velocity = Vector2.ZERO
			position = position.normalized()*travel_distance
		if velocity.length_squared() > 100000 and not speed_check and ship_speed == location.Galaxy:
			emit_signal("speed_check",true)
			speed_check = true
		elif velocity.length_squared() < 100000 and speed_check and ship_speed == location.Galaxy:
			emit_signal("speed_check",false)
			speed_check = false
		rotation_speed = 1.5/(abs(velocity.x)/turn_divisor+abs(velocity.y)/turn_divisor+1)
		velocity = velocity.linear_interpolate(Vector2(0,0), friction * delta)
		if velocity.length() < .1:
			velocity = Vector2.ZERO
			jet_particles.emitting = false
		else:
			jet_particles.emitting = true
		var current_speed_step = str(stepify((velocity.length()*max_speed_unit/500),.01))
		if "." in current_speed_step:
			var speed_string_split = current_speed_step.split(".")
			for item in 5 - speed_string_split[0].length():
				current_speed_step = " " + current_speed_step
			for item in 2 - speed_string_split[1].length():
				current_speed_step += " "
		elif current_speed_step == "0":
			current_speed_step = "    0   "
		else:
			for item in 5 - current_speed_step.length():
				current_speed_step = " " + current_speed_step
			current_speed_step += "   "
		if ship_speed == location.Galaxy:
			speed_overlay.text = current_speed_step + " ly/s"
		elif ship_speed == location.System or ship_speed == location.None:
			speed_overlay.text = current_speed_step + " ls/s"
	else:
		overlay.visible = false
var speed_check = false
signal speed_check
# Original ship code

#var input_vector : Vector2
#var velocity : Vector2
#export (int) var acceleration = 1000
#export (int) var max_speed = 300
#var rotation_direction : int
#export (float) var stationary_rotation_speed = 3.5
#var rotation_speed = 3.5
#
#export (float) var friction_weight = 0.5
#
#func _ready():
#	rotation = GalaxySave.game_data["shipPosition"][3]
#
#func _physics_process(delta):
#	input_vector.x = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
#	rotation_direction = 0
#	if Input.is_action_pressed("move_right"):
#		rotation_direction += 1
#	if Input.is_action_pressed("move_left"):
#		rotation_direction += -1
#
#	velocity += Vector2(input_vector.x * acceleration * delta,0).rotated(rotation)
#	velocity.x = clamp(velocity.x,-max_speed,max_speed)
#	velocity.y = clamp(velocity.y,-max_speed,max_speed)
#
#	if input_vector.x == 0 && velocity != Vector2.ZERO:
#		velocity = lerp(velocity,Vector2.ZERO, friction_weight)
#		if abs(velocity.x) <= 0.1:
#			velocity.x = 0
#		if abs(velocity.y) <= 0.1:
#			velocity.y = 0
#
#	rotation_speed = stationary_rotation_speed * 1/((abs(velocity.x)+abs(velocity.y))/100+1)
#	rotation += rotation_direction * rotation_speed * delta
#	var _move_slide = move_and_slide(velocity)
