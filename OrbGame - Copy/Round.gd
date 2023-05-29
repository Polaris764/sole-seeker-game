extends KinematicBody2D

export var ACCELERATION = 300

export var MAX_SPEED = 50

export var PERSISTANCE = 1 # ability to counter speed traps

var current_max_speed : int

export var FRICTION = 200

export var WANDER_TARGET_RANGE = 4

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
onready var sprite = $Body0

onready var bodySprites = [$Body0,$Body1,$Body2,$Body3,$Body4,$Body5,$Body6,$Body7,$Body8]
onready var crystalSprites = [$Crystals0,$Crystals1,$Crystals2,$Crystals3,$Crystals4,$Crystals5,$Crystals6,$Crystals7,$Crystals8]

func _ready():
	for item in get_children():
		if "Body" in item.name:
			bodySprites.append(item)
	sprite.scale = Vector2(1,1)
	current_max_speed = MAX_SPEED
	set_sprite_distances()

export var map_size : int = 0
func set_sprite_distances():
	map_size *= 16
	var sprite_map_size = map_size * (1/scale.x)
	bodySprites[1].position = Vector2(sprite_map_size,0)
	bodySprites[2].position = Vector2(sprite_map_size,-sprite_map_size)
	bodySprites[3].position = Vector2(0,-sprite_map_size)
	bodySprites[4].position = Vector2(-sprite_map_size,-sprite_map_size)
	bodySprites[5].position = Vector2(-sprite_map_size,0)
	bodySprites[6].position = Vector2(-sprite_map_size,sprite_map_size)
	bodySprites[7].position = Vector2(0,sprite_map_size)
	bodySprites[8].position = Vector2(sprite_map_size,sprite_map_size)
	crystalSprites[1].position = Vector2(sprite_map_size,0)
	crystalSprites[2].position = Vector2(sprite_map_size,-sprite_map_size)
	crystalSprites[3].position = Vector2(0,-sprite_map_size)
	crystalSprites[4].position = Vector2(-sprite_map_size,-sprite_map_size)
	crystalSprites[5].position = Vector2(-sprite_map_size,0)
	crystalSprites[6].position = Vector2(-sprite_map_size,sprite_map_size)
	crystalSprites[7].position = Vector2(0,sprite_map_size)
	crystalSprites[8].position = Vector2(sprite_map_size,sprite_map_size)
onready var last_seen_player_location = global_position
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,200*delta)
	knockback = move_and_slide(knockback)
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
		TRAPPED:
			current_max_speed = MAX_SPEED*trapped_speeds.min() if trapped_speeds.min() else MAX_SPEED
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction*current_max_speed,ACCELERATION*delta)
			
			if global_position.distance_to(wander_controller.target_position) <= 4:
				state = pick_random_state([IDLE,WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
		DEAD:
			velocity = Vector2.ZERO
			MAX_SPEED = 0
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector()*delta*400
	if velocity.x > 0:
		for item in bodySprites:
			item.rotation_degrees += 1
	elif velocity.x < 0:
		for item in bodySprites:
			item.rotation_degrees -= 1
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
			$AnimationPlayer.play("EyeOpen")

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
		$AnimationPlayer.play("Harvest")

func _on_Stats_no_health():
	death_animation()

func death_animation():
	state = DEAD
	$Hitbox.queue_free()
	$AnimationPlayer.play_backwards("Agro")
	var tween = sprite.get_node("DeathTween")
	tween.interpolate_property(sprite, "offset",
			sprite.offset, Vector2(0,0), 2,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	tween.interpolate_property($ShadowSprite0, "scale",
			sprite.scale, Vector2(0,0), 2,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	tween.interpolate_property($Hurtbox/CollisionShape2D, "position",
			$Hurtbox/CollisionShape2D.position, Vector2(0,0), 2,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	for child in sprite.get_children():
		if child is Sprite:
			tween = child.get_node("DeathTween")
			tween.interpolate_property(child, "offset",
					child.offset, Vector2(0,0), 2,
					Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
	for child in $ShadowSprite0.get_children():
		tween.interpolate_property(child, "scale",
				sprite.scale, Vector2(0,0), 2,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
func completed_harvest():
	harvest_area.harvesting = false
	GalaxySave.game_data["backpackBlood"]["red"] += 1
	print(GalaxySave.game_data["backpackBlood"])
	GalaxySave.save_data()
	for child in sprite.get_children():
		if child is Sprite:
			child.position *= Vector2(1/.8,1/.8)

# Trapped Functions #

var trapped_speeds = []

func _on_TrappedTimer_timeout(trapped_speed_used,timer_used):
	trapped_speeds.remove(trapped_speeds.find(trapped_speed_used))
	if trapped_speeds.min():
		current_max_speed = MAX_SPEED*trapped_speeds.min()
		state = TRAPPED
	else:
		current_max_speed = MAX_SPEED
		state = WANDER
	timer_used.queue_free()

func entity_trapped(duration,speed):
	state = TRAPPED
	velocity = Vector2.ZERO
	trapped_speeds.append(speed)
	var timer = Timer.new()
	timer.connect("timeout",self,"_on_TrappedTimer_timeout",[speed,timer])
	add_child(timer)
	timer.wait_time = duration
	timer.start()
