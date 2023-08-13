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
onready var sprite = $Sprite0
onready var sprite2 = $Sprite2

#warning-ignore:unused_signal
signal direction_changed

func _ready():
	sprite.visible = false
	sprite2.visible = false
	sprite.scale = Vector2(1,1)
	current_max_speed = MAX_SPEED
	set_sprite_distances()

export var map_size : int = 0
func set_sprite_distances():
	map_size *= 16
	var sprite_map_size = map_size * (1/scale.x)
	sprite.get_node("Sprite1").position = Vector2(sprite_map_size,0)
	sprite.get_node("Sprite2").position = Vector2(sprite_map_size,-sprite_map_size)
	sprite.get_node("Sprite3").position = Vector2(0,-sprite_map_size)
	sprite.get_node("Sprite4").position = Vector2(-sprite_map_size,-sprite_map_size)
	sprite.get_node("Sprite5").position = Vector2(-sprite_map_size,0)
	sprite.get_node("Sprite6").position = Vector2(-sprite_map_size,sprite_map_size)
	sprite.get_node("Sprite7").position = Vector2(0,sprite_map_size)
	sprite.get_node("Sprite8").position = Vector2(sprite_map_size,sprite_map_size)
	sprite2.get_node("Sprite1").position = Vector2(sprite_map_size,0)
	sprite2.get_node("Sprite2").position = Vector2(sprite_map_size,-sprite_map_size)
	sprite2.get_node("Sprite3").position = Vector2(0,-sprite_map_size)
	sprite2.get_node("Sprite4").position = Vector2(-sprite_map_size,-sprite_map_size)
	sprite2.get_node("Sprite5").position = Vector2(-sprite_map_size,0)
	sprite2.get_node("Sprite6").position = Vector2(-sprite_map_size,sprite_map_size)
	sprite2.get_node("Sprite7").position = Vector2(0,sprite_map_size)
	sprite2.get_node("Sprite8").position = Vector2(sprite_map_size,sprite_map_size)

onready var last_seen_player_location = global_position

func _physics_process(_delta):
	if playerDetectionZone.can_see_player():
		if state == IDLE:
			state = CHASE
			if audio:
				if not audio.playing:
					audio.stream = audioTracks["idle"]
					audio.play()
			animator.play("Agro")
			attackT.start(rand_range(attack_min,attack_max))
	else:
		if state != IDLE:
			state = IDLE
		if not animator.is_playing() and sprite.frame == 0:
			animator.play_backwards("Agro")

func _on_AttackCountdown_timeout():
	if state == CHASE:
		queued_attack = true

func attack():
	queued_attack = false
	if audio:
		audio.stream = audioTracks["attack"]
		audio.play()
	if global_position.x > player.global_position.x:
		animator.play("AttackLeft")
	else:
		animator.play("AttackRight")
	attackT.start(rand_range(attack_min,attack_max))

func attack_animation_ended():
	if state == CHASE:
		animator.play("Aggressive")
		if audio:
			audio.stream = audioTracks["idle"]
			audio.play()
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
	audio.queue_free()
	$Hitbox.queue_free()
	var _tween = $Sprite/DeathTween
	GalaxySave.game_data["individualKills"]["green"] += 1

func completed_harvest():
	harvest_area.harvesting = false
	GalaxySave.game_data["backpackBlood"]["purple"] += 1
	print(GalaxySave.game_data["backpackBlood"])
	GalaxySave.save_data()
	for child in sprite.get_children():
		if child is Sprite:
			child.position *= Vector2(1/.8,1/.8)
	for child in sprite2.get_children():
		if child is Sprite:
			child.position *= Vector2(1/.8,1/.8)

# Trapped Functions #

var trapped_speeds = []
signal organism_trapped
func entity_trapped(_var1,_var2):
	emit_signal("organism_trapped")

# Audio #

onready var audio = $purpleAudio
var audioTracks = {
"idle":preload("res://Audio/EnemySounds/greenIdle.wav"),
"attack":preload("res://Audio/EnemySounds/greenAttack.wav")
}
