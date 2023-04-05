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
onready var attackT = $AttackCountdown
onready var player = get_node("../Player")

func _ready():
	$Sprite.visible = false
	$Sprite2.visible = false
	$Sprite.scale = Vector2(1,1)
	current_max_speed = MAX_SPEED

func _physics_process(delta):
	if playerDetectionZone.can_see_player():
		if state == IDLE:
			state = CHASE
			print("chasing")
			animator.play("Agro")
			attackT.start(rand_range(attack_min,attack_max))
	else:
		if state != IDLE:
			state = IDLE
		if not animator.is_playing() and $Sprite.frame == 0:
			animator.play_backwards("Agro")

func _on_AttackCountdown_timeout():
	if state == CHASE:
		queued_attack = true

func attack():
	queued_attack = false
	if global_position.x > player.global_position.x:
		animator.play("AttackLeft")
	else:
		animator.play("AttackRight")
	attackT.start(rand_range(attack_min,attack_max))

func attack_animation_ended():
	if state == CHASE:
		animator.play("Aggressive")
	else:
		animator.play_backwards("Agro")
func agg_animation_ended():
	if state == IDLE:
		animator.play_backwards("Agro")
	elif queued_attack:
		attack()

func agro_animation_ended():
	if state == CHASE:
		animator.play("Aggressive")

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
		$AnimationPlayer.play("Harvest")

func _on_Stats_no_health():
	death_animation()

func death_animation():
	state = DEAD
	animator.stop()
	$Hitbox.queue_free()
	var tween = $Sprite/DeathTween

func completed_harvest():
	harvest_area.harvesting = false
	GalaxySave.game_data["backpackBlood"]["purple"] += 1
	print(GalaxySave.game_data["backpackBlood"])
	GalaxySave.save_data()

# Trapped Functions #

var trapped_speeds = []


