extends KinematicBody2D

var input_vector : Vector2
var velocity : Vector2
export (int) var acceleration = 1000
export (int) var max_speed = 300
var rotation_direction : int
export (float) var rotation_speed = 3.5

export (float) var friction_weight = 0.5


func _physics_process(delta):
	input_vector.x = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	rotation_direction = 0
	if Input.is_action_pressed("move_right"):
		rotation_direction += 1
	if Input.is_action_pressed("move_left"):
		rotation_direction += -1
	
	velocity += Vector2(input_vector.x * acceleration * delta,0).rotated(rotation)
	velocity.x = clamp(velocity.x,-max_speed,max_speed)
	velocity.y = clamp(velocity.y,-max_speed,max_speed)
	
	if input_vector.x == 0 && velocity != Vector2.ZERO:
		velocity = lerp(velocity,Vector2.ZERO, friction_weight)
		if abs(velocity.x) <= 0.1:
			velocity.x = 0
		if abs(velocity.y) <= 0.1:
			velocity.y = 0
	
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide(velocity)
