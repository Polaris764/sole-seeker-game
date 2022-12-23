extends KinematicBody2D

var current_velocity := Vector2()
var input_velocity : Vector2 = Vector2()
var direction : Vector2 = Vector2()
var movementSpeed = 100
export var isInShip = false
export var slipperyGround = false
export var frozenPlanet = false
var recent_vectors = []

func read_input():
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

func check_for_ice():
	var grass_tilemap = get_node("../Grass")
	var playerPos = Vector2(grass_tilemap.world_to_map(global_position).x,grass_tilemap.world_to_map(global_position+Vector2(0,5)).y)
	var playerPos2 = Vector2(grass_tilemap.world_to_map(global_position+Vector2(8,0)).x,grass_tilemap.world_to_map(global_position+Vector2(0,-7)).y)
	if grass_tilemap.get_cell(playerPos.x,playerPos.y) == -1 or grass_tilemap.get_cell(playerPos2.x,playerPos2.y) == -1 :
		return true
	else:
		return false

var isOnIce = false
func _physics_process(delta):
	if frozenPlanet:
		isOnIce = check_for_ice()
	read_input()
	#print(self.global_position)
