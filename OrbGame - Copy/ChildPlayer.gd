extends KinematicBody2D

export var current_velocity := Vector2()
export var input_velocity : Vector2 = Vector2()
export var movementSpeed = 50
export var panic_movement_speed = 100
var backward_slowdown_multiplier = 1
export var backward_slowdown_multiplier_val = .2
export var cutscene = []
onready var animationTree = $AnimationTree
onready var animationPlayer = $AnimationPlayer
onready var animationState = animationTree.get("parameters/StateMachine/playback")
var panic = false

func set_panic():
	panic = true
	movementSpeed = panic_movement_speed
	backward_slowdown_multiplier = backward_slowdown_multiplier_val

func _physics_process(_delta):
	move_player()

func move_player():
	input_velocity = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_velocity.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_velocity.y += 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
	if input_velocity != Vector2.ZERO:
		input_velocity = input_velocity.normalized()
		animationTree.set("parameters/StateMachine/Idle/blend_position",input_velocity)
		animationTree.set("parameters/StateMachine/Walk/blend_position",input_velocity)
		animationState.travel("Walk")
		if input_velocity.y > 0:
			if panic:
				animationTree.set("parameters/TimeScale/scale",.5)
			#moving backward
			current_velocity = move_and_slide(input_velocity*(movementSpeed*backward_slowdown_multiplier))
		else:
			current_velocity = move_and_slide(input_velocity*movementSpeed)
			if panic:
				animationTree.set("parameters/TimeScale/scale",1)
	else:
		animationState.travel("Idle")


# HEALTH
export var health := 3 setget health_changed
onready var regen = $HealthTimer

func health_changed(value):
	health += value
	regen.start(2)
	var hearts = $CanvasLayer/HealthUI.get_children()
	for image in hearts:
		image.visible = false
	if health == 3:
		$CanvasLayer/HealthUI/HeartUIStage3.visible = true
	elif health == 2:
		$CanvasLayer/HealthUI/HeartUIStage2.visible = true
	elif health == 1:
		$CanvasLayer/HealthUI/HeartUIStage1.visible = true
	else:
		pass

func _on_HealthTimer_timeout():
	self.health = 3-health

onready var footstepAudio = $FootstepAudio
func play_footstep_sound():
	var newPlayer = AudioStreamPlayer.new()
	newPlayer.volume_db = footstepAudio.volume_db
	newPlayer.pitch_scale = footstepAudio.pitch_scale
	newPlayer.stream = footstepAudio.stream
	add_child(newPlayer)
	newPlayer.play()
	newPlayer.connect("finished",newPlayer,"queue_free")
