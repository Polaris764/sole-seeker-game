extends KinematicBody2D

## MOVEMENT VARIABLES ##

var current_velocity := Vector2()
var input_velocity : Vector2 = Vector2()
var direction : Vector2 = Vector2()
var movementSpeed = 100
export var isInShip = false
export var slipperyGround = false
export var frozenPlanet = false
var recent_vectors = []
var isOnIce = false

### 

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var weaponHitbox = $HitboxPivot/WeaponHitbox

enum {
	MOVE,
	ATTACK,
	HARVEST
}
var state = MOVE

func _ready():
	animationTree.active = true
	weaponHitbox.knockback_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			move_state()
			attack_state(delta)
		HARVEST:
			pass
#	print(self.global_position)

## MOVING ##

func move_state():
	if frozenPlanet:
		isOnIce = check_for_ice()
	input_velocity = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_velocity.y -= 1
		direction = Vector2(0,-1)
	if Input.is_action_pressed("move_backward"):
		input_velocity.y += 1
		direction = Vector2(0,1)
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
		direction = Vector2(-1,0)
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
		direction = Vector2(1,0)
	input_velocity = input_velocity.normalized()
	
	if slipperyGround or isOnIce:
		if input_velocity != Vector2.ZERO:
			current_velocity = move_and_slide(input_velocity*movementSpeed)
			if recent_vectors.size() == 2:
				recent_vectors.remove(0)
			recent_vectors.append(current_velocity)
		elif abs(current_velocity.x) > .1 or abs(current_velocity.y) > .1:
			if slipperyGround:
				current_velocity = move_and_slide(recent_vectors[0] * Vector2(.88,.88))
			else:
				current_velocity = move_and_slide(recent_vectors[0] * Vector2(.98,.98))
			recent_vectors[0] = current_velocity
		else:
			current_velocity = move_and_slide(Vector2(0,0))
	else:
		current_velocity = move_and_slide(input_velocity*movementSpeed)
	if input_velocity != Vector2.ZERO:
		weaponHitbox.knockback_vector = input_velocity
		animationState.travel("Run")
		animationTree.set("parameters/Run/blend_position",input_velocity)
		animationTree.set("parameters/Idle/blend_position",input_velocity)
		animationTree.set("parameters/AttackRun/blend_position",input_velocity)
		animationTree.set("parameters/AttackIdle/blend_position",input_velocity)
		$AttackTree.set("parameters/Attack/blend_position",input_velocity)
	else:
		animationState.travel("Idle")
	if not isInShip:
		var map_size = get_node("../..").map_side_size*16 if not get_node("../..").get("map_side_size") == null else get_node("..").map_side_size*16
		if self.global_position.x < 0:
			self.global_position.x += map_size
		elif self.global_position.x > map_size:
			self.global_position.x -= map_size
		if self.global_position.y < 0:
			self.global_position.y += map_size
		elif self.global_position.y > map_size:
			self.global_position.y -= map_size
	
	if Input.is_action_just_pressed("attack") and state == MOVE:
		print("attack started")
		$AttackTree.set("parameters/Seek/seek_position",0)
		state = ATTACK
		$AttackTree.active = true
		yield(get_tree().create_timer(.65), "timeout")
		attack_animation_finished2()

func check_for_ice():
	var grass_tilemap = get_node("../Grass")
	var playerPos = Vector2(grass_tilemap.world_to_map(global_position).x,grass_tilemap.world_to_map(global_position+Vector2(0,5)).y)
	var playerPos2 = Vector2(grass_tilemap.world_to_map(global_position+Vector2(8,0)).x,grass_tilemap.world_to_map(global_position+Vector2(0,-2)).y)
	if grass_tilemap.get_cell(playerPos.x,playerPos.y) == -1 or grass_tilemap.get_cell(playerPos2.x,playerPos2.y) == -1 :
		return true
	else:
		return false

## ATTACKING ##

func attack_state(delta):
	if input_velocity == Vector2.ZERO:
		animationState.travel("AttackIdle")
	else:
		animationState.travel("AttackRun")

func attack_animation_finished2():
	print("attack finished")
	$AttackTree.active = false
	state = MOVE

func attack_animation_finished():
	pass
## TODO
# Sync walk animations
