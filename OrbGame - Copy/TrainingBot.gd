extends KinematicBody2D

export var movement_duration = 3
onready var animator = $AnimationPlayer
onready var timer = $MovementTimer
var moving = false #false = left, true = right
var velocity = Vector2(0,0)
export var movement_speed_used : int
onready var speed_of_travel = movement_speed_used
export var active = false setget activate
var initial_time = 6
onready var glass = $Glass

func _ready():
	glass.speed_scale = 1/stats.harvest_duration
	glass.frame = 0

func activate(_value):
	active = true
	$RobotAudio.play()
	velocity = Vector2(1,0)
	if timer:
		timer.start(initial_time)

func _on_MovementTimer_timeout():
	if stats.health > 0:
		moving = not moving
		if moving:
			animator.play("WalkRight")
			velocity = Vector2(1,0)
		else:
			animator.play("WalkLeft")
			velocity = Vector2(-1,0)
		timer.start(movement_duration)

func _physics_process(delta):
	if stats.health > 0:
		knockback = knockback.move_toward(Vector2.ZERO,200*delta)
		knockback = move_and_slide(knockback)
		position = position + velocity * speed_of_travel * delta

onready var stats = $Stats
var harvest_area = null
var knockback = Vector2.ZERO
onready var hurtbox = $Hurtbox
func _on_Hurtbox_area_entered(area): # needle entered hitbox
	if stats.health > 0: # if still alive
		stats.health -= area.damage
		knockback = area.knockback_vector * 30
		hurtbox.create_hit_effect()
	elif area.harvesting_tool == true: # harvest
		area.harvesting = true
		area.harvest_wait_time = stats.harvest_duration
		harvest_area = area
		$Hurtbox.queue_free()
		glass.play("default")

onready var smoke_sprite = $SmokeSprite
func _on_Stats_no_health():
	smoke_sprite.visible = true
	smoke_sprite.play("default")
	animator.queue_free()
	$RobotAudio.stop()

func entity_trapped(duration,_speed):
	speed_of_travel = movement_speed_used*.02
	var timer2 = Timer.new()
	timer2.connect("timeout",self,"_on_TrappedTimer_timeout",[timer2])
	add_child(timer2)
	timer2.wait_time = duration
	timer2.start()
	timer.paused = true
	timer.wait_time -= duration*.02
	
func _on_TrappedTimer_timeout(timer_used):
	speed_of_travel = movement_speed_used
	timer_used.queue_free()
	timer.paused = false


func _on_SmokeSprite_animation_finished():
	smoke_sprite.queue_free()


func _on_Glass_animation_finished(): # harvest completed
	harvest_area.harvesting = false
	GalaxySave.game_data["storyProgression"] = 4
	GalaxySave.save_data()
	SignalBus.emit_signal("updated_story")
	SignalBus.emit_signal("display_announcement","completed_tutorial")
