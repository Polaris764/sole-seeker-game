extends KinematicBody2D

export var ACCELERATION = 300

export var MAX_SPEED = 50

export var PERSISTANCE = 1 # ability to counter speed traps

var current_max_speed : int

export var FRICTION = 200

export var WANDER_TARGET_RANGE = 4

export var is_in_room = false

enum{
	IDLE,
	WANDER,
	CHASE,
	TRAPPED,
	DEAD
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var sprite = $Sprite0

func _ready():
	sprite.speed_scale = rand_range(.95,1.05)
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

onready var last_seen_player_location = global_position
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,200*delta)
	knockback = move_and_slide(knockback)
	if not is_in_room:
		handle_map_teleportation()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200*delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction*current_max_speed,ACCELERATION*delta)
			
			if global_position.distance_to(wander_controller.target_position) <= 4:
				state = pick_random_state([IDLE,WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var player_location = player.get_node("Hurtbox/CollisionShape2D").global_position
				last_seen_player_location = global_position + Vector2(10,10) * velocity
				var direction = global_position.direction_to(player_location)
				velocity = velocity.move_toward(direction*current_max_speed,ACCELERATION*delta)
			else:
				var direction = global_position.direction_to(last_seen_player_location)
				velocity = velocity.move_toward(direction*current_max_speed,ACCELERATION*delta)
				if global_position.distance_to(last_seen_player_location) < 1:
					state = IDLE
		DEAD:
			velocity = Vector2.ZERO
			MAX_SPEED = 0
	if state != DEAD and soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector()*delta*400
	velocity = move_and_slide(velocity)

func handle_map_teleportation():
	if self.global_position.x < 0:
		self.global_position.x += map_size
		last_seen_player_location.x += map_size
	elif self.global_position.x > map_size:
		self.global_position.x -= map_size
		last_seen_player_location.x -= map_size
	if self.global_position.y < 0:
		self.global_position.y += map_size
		last_seen_player_location.y += map_size
	elif self.global_position.y > map_size:
		self.global_position.y -= map_size
		last_seen_player_location.y -= map_size

var seen_player = false
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		if not seen_player:
			seen_player = true

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

var harvest_area = null
func _on_Hurtbox_area_entered(area): # needle entered hitbox
	if stats.health > 0: # if still alive
		stats.health -= area.damage
		print(stats.health)
		knockback = area.knockback_vector * 30
		hurtbox.create_hit_effect()
	elif area.harvesting_tool == true: # harvest
		area.harvesting = true
		area.harvest_wait_time = stats.harvest_duration
		harvest_area = area
		$Hurtbox.queue_free()

func _on_Stats_no_health():
	death_animation()

func death_animation():
	state = DEAD
	$Hurtbox.queue_free()
	var tween = $Sprite0/DeathTween
	sprite.stop()
	tween.interpolate_property(sprite, "offset",
			sprite.offset, Vector2(0,0), 1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	var childrenSprites = sprite.get_children()
	childrenSprites.erase($Sprite0/DeathTween)
	for child in childrenSprites:
		child.stop()
		tween.interpolate_property(child, "offset",
			child.offset, Vector2(0,0), 1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
	GalaxySave.game_data["individualKills"]["black"] += 1
# Trapped Functions #

var trapped_speeds = []
