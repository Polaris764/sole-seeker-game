extends KinematicBody2D

export var ACCELERATION = 300

export var MAX_SPEED = 50

export var PERSISTANCE = 1 # ability to counter speed traps

var current_max_speed : int

export var FRICTION = 200

export var WANDER_TARGET_RANGE = 4

enum{
	IDLE,
	CHASE,
	DEAD
}

export var attack_min = 3
export var attack_max = 8
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE
var queued_attack = true

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var animator = $AnimationPlayer
onready var animator2 = $Body/BaseL/BaseLAnimator
onready var animator3 = $Body/BaseR/BaseRAnimator
onready var attackT = $AttackCountdown
onready var player = get_node("../Player")

func _ready():
	animator.play("Idle")
	$SplurtCountdown.start(rand_range(.4,4))

func _physics_process(delta):
	if playerDetectionZone.can_see_player():
		if state == IDLE:
			state = CHASE
			attackT.start(rand_range(attack_min,attack_max))
	else:
		if state != IDLE:
			state = IDLE

func _on_AttackCountdown_timeout():
	if state == CHASE:
		queued_attack = true

func attack():
	queued_attack = false
	animator.play("Attack")
	attackT.start(rand_range(attack_min,attack_max))

func attack_animation_ended():
	animator.play("Idle")

func agg_animation_ended():
	if queued_attack:
		attack()

var harvest_area = null
func _on_Hurtbox_area_entered(area): # needle entered hitbox
	if stats.health > 0: # if still alive
		stats.health -= area.damage
		print(stats.health)
		hurtbox.create_hit_effect()
	elif area.harvesting_tool == true: # harvest
		area.harvesting = true
		area.harvest_wait_time = stats.harvest_duration
		harvest_area = area
		$Hurtbox.queue_free()
		animator.play("Harvest")

func _on_Stats_no_health():
	death_animation()

func death_animation():
	state = DEAD
	animator.stop()
	var tween = $Body/DeathTween

func completed_harvest():
	harvest_area.harvesting = false
	GalaxySave.game_data["backpackBlood"]["orange"] += 1
	print(GalaxySave.game_data["backpackBlood"])
	GalaxySave.save_data()

func _on_SplurtCountdown_timeout():
	if state != DEAD:
		var choices = [0,1,2,3]
		var choice = randi()%choices.size()
		match choice:
			1:
				if not animator2.is_playing():
					animator2.play("Burst")
			2:
				if not animator3.is_playing():
					animator3.play("Burst")
			3:
				if not animator2.is_playing():
					animator2.play("Burst")
				if not animator3.is_playing():
					animator3.play("Burst")
		$SplurtCountdown.start(rand_range(.2,4))

# Trapped Functions #

var trapped_speeds = []
