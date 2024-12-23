extends KinematicBody2D

## MOVEMENT VARIABLES ##

var current_velocity := Vector2()
var input_velocity : Vector2 = Vector2()
var direction : Vector2 = Vector2()
var movementSpeed = 100
export var isInRoom = false
export var slipperyGround = false
export var frozenPlanet = false
var recent_vectors = []
var isOnIce = false

### 

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var weaponHitbox = $HitboxPivot/WeaponHitbox
onready var hurtbox = $Hurtbox

# Player states
enum {
	MOVE,
	ATTACK,
	HARVEST,
	BUILD
}
var state = MOVE
var stats = PlayerStats

# Player weapons
enum player_weapons {
	NEEDLE,
	NETGUN
}
var weapon = player_weapons.NETGUN
var needle_attack_with_netgun_equipped = false


func _ready():
	stats.connect("no_health",self,"queue_free")
	animationTree.active = true
	weaponHitbox.knockback_vector
	update_buildings_from_saved_data()

func _physics_process(delta):
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			move_state()
			match weapon:
				player_weapons.NEEDLE:
					attack_state(delta)
				player_weapons.NETGUN:
					attack_state_NETGUN(delta)
		HARVEST:
			harvest_state()
		BUILD:
			move_state()
			build_state(delta)
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
		match weapon:
			player_weapons.NEEDLE:
				animationState.travel("Run")
			player_weapons.NETGUN:
				animationState.travel("NetgunRun")
		set_positions_of_animation_trees(input_velocity)
	else:
		match weapon:
			player_weapons.NEEDLE:
				animationState.travel("Idle")
			player_weapons.NETGUN:
				animationState.travel("NetgunIdle")
	if not isInRoom:
		var map_size = get_node("../..").map_side_size*16 if not get_node("../..").get("map_side_size") == null else get_node("..").map_side_size*16
		if self.global_position.x < 0:
			self.global_position.x += map_size
		elif self.global_position.x > map_size:
			self.global_position.x -= map_size
		if self.global_position.y < 0:
			self.global_position.y += map_size
		elif self.global_position.y > map_size:
			self.global_position.y -= map_size
	
	# switching weapons
	if Input.is_action_just_released("weapon_switch_down"):
		match state:
			MOVE:
				weapon += 1
				if weapon > player_weapons.size()-1:
					weapon = 0
				print("going down")
			BUILD:
				current_building_type += 1
				if current_building_type > building_types.size()-1:
					current_building_type = 0
				var mousepos = get_global_mouse_position()
				var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, floor(mousepos.y/tile_size)*tile_size)
				update_guides(mousepos_floored)
	elif Input.is_action_just_released("weapon_switch_up"):
		match state:
			MOVE:
				weapon -= 1
				if weapon < 0:
					weapon = player_weapons.size()-1
				print("going up")
			BUILD:
				current_building_type -= 1
				if current_building_type < 0:
					current_building_type = building_types.size()-1
				var mousepos = get_global_mouse_position()
				var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, floor(mousepos.y/tile_size)*tile_size)
				update_guides(mousepos_floored)
				print("going up")
	
	# building
	if Input.is_action_just_pressed("build_state_switch"):
		print(state)
		if state == MOVE:
			state = BUILD
			var mousepos = get_global_mouse_position()
			var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, floor(mousepos.y/tile_size)*tile_size)
			update_guides(mousepos_floored)
		elif state == BUILD:
			state = MOVE
			clear_all_guides()
	
	# detecting attacks
	if Input.is_action_just_pressed("attack") and state == MOVE:
		match weapon:
			player_weapons.NEEDLE:
				print("attack started")
				$AttackTree.set("parameters/Seek/seek_position",0)
				state = ATTACK
				weaponHitbox.harvesting_tool = false
				$AttackTree.active = true
				yield(get_tree().create_timer(.65), "timeout")
				attack_animation_finished2()
			player_weapons.NETGUN:
				print("attack started")
				$NetgunTree.set("parameters/Seek/seek_position",0)
				state = ATTACK
				weaponHitbox.harvesting_tool = false
				$NetgunTree.active = true
				yield(get_tree().create_timer(.1), "timeout")
				fire_netgun_create_projectiles()
				yield(get_tree().create_timer(1.9), "timeout")
				netgun_attack_animation_finished()
				
	elif Input.is_action_just_pressed("harvest") and state == MOVE:
		print("harvest started")
		state = ATTACK
		weaponHitbox.harvesting_tool = true
		$AttackTree.active = true
		if weapon == player_weapons.NETGUN:
			needle_attack_with_netgun_equipped = true
		yield(get_tree().create_timer(.05), "timeout")
		pause_animation($AttackTree,0.05)
		yield(get_tree().create_timer(.25), "timeout")
		state = HARVEST
		harvest_check()

func check_for_ice():
	var grass_tilemap = get_node("../Grass")
	var playerPos = Vector2(grass_tilemap.world_to_map(global_position).x,grass_tilemap.world_to_map(global_position+Vector2(0,5)).y)
	var playerPos2 = Vector2(grass_tilemap.world_to_map(global_position+Vector2(8,0)).x,grass_tilemap.world_to_map(global_position+Vector2(0,-2)).y)
	if grass_tilemap.get_cell(playerPos.x,playerPos.y) == -1 or grass_tilemap.get_cell(playerPos2.x,playerPos2.y) == -1 :
		return true
	else:
		return false

func set_positions_of_animation_trees(target_velocity):
	animationTree.set("parameters/Run/blend_position",target_velocity)
	animationTree.set("parameters/Idle/blend_position",target_velocity)
	animationTree.set("parameters/AttackRun/blend_position",target_velocity)
	animationTree.set("parameters/AttackIdle/blend_position",target_velocity)
	animationTree.set("parameters/ArmlessRun/blend_position",target_velocity)
	animationTree.set("parameters/ArmlessIdle/blend_position",target_velocity)
	animationTree.set("parameters/NetgunRun/blend_position",target_velocity)
	animationTree.set("parameters/NetgunIdle/blend_position",target_velocity)
	$NetgunTree.set("parameters/NetgunAttack/blend_position",target_velocity)
	$AttackTree.set("parameters/Attack/blend_position",target_velocity)
	
## ATTACKING ##

func attack_state(delta):
	if state != HARVEST:
		if input_velocity == Vector2.ZERO:
			animationState.travel("AttackIdle")
		else:
			animationState.travel("AttackRun")

func attack_animation_finished2():
	print("attack finished")
	$AttackTree.active = false
	needle_attack_with_netgun_equipped = false
	state = MOVE

func harvest_state():
	animationState.travel("AttackIdle")

func harvest_check():
	if not weaponHitbox.harvesting:
		print("no target")
	else:
		print("waiting")
		yield(get_tree().create_timer(weaponHitbox.harvest_wait_time), "timeout")
	weaponHitbox.harvesting_tool = false
	play_animation($AttackTree)
	print("harvest finished")
	state = ATTACK

func harvest_end():
	$AttackTree.active = false
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()

func pause_animation(player,time_position):
	player.set("parameters/TimeScale/scale",0)
	$AttackTree.set("parameters/Seek/seek_position",time_position)
func play_animation(player):
	player.set("parameters/TimeScale/scale",1)

## Attacking With Netgun ##

func attack_state_NETGUN(delta):
	if not needle_attack_with_netgun_equipped:
		if input_velocity == Vector2.ZERO:
			animationState.travel("ArmlessIdle")
		else:
			animationState.travel("ArmlessRun")
	else:
		if input_velocity == Vector2.ZERO:
			animationState.travel("AttackIdle")
		else:
			animationState.travel("AttackRun")

func netgun_attack_animation_finished():
	print("netgun attack finished")
	$NetgunTree.active = false
	state = MOVE

var net_projectiles = preload("res://OnFootAssets/Player/Netgun/NetProjectile.tscn")
func fire_netgun_create_projectiles():
	for body in $HitboxPivot/NetgunHitbox.get_overlapping_bodies():
		var projectile = net_projectiles.instance()
		var projectile_sprite = projectile.get_node("ProjectileSprite")
		var net_sprite = projectile.get_node("NetSprite")
		projectile_sprite.frame = rand_range(0,projectile_sprite.hframes) # number of net image possibilities
		net_sprite.frame = rand_range(0,net_sprite.hframes)
		get_tree().get_root().add_child(projectile)
		projectile.start($HitboxPivot/NetProjectileOrigin.global_transform,body)
		print("making net")

## Building ##

var tile_size = 16
onready var planet_building_data = GalaxySave.get_planet_building_data()
var guide_frame = preload("res://OnFootAssets/Player/Build/GuideFrameTilemap.tscn")
var wall_scene = preload("res://OnFootAssets/Player/Build/WallTilemap.tscn")
var wall_guide_scene = preload("res://OnFootAssets/Player/Build/WallTilemapGuide.tscn")
var floor_scene = preload("res://OnFootAssets/Player/Build/CleanFloorTilemap.tscn")
var landmine_scene = preload("res://OnFootAssets/Player/Build/Landmines.tscn")
var landmine_guide_scene = preload("res://OnFootAssets/Player/Build/LandmineGuide.tscn")
var caltrops_scene = preload("res://OnFootAssets/Player/Build/Caltrops.tscn")
var caltrops_guide_scene = preload("res://OnFootAssets/Player/Build/CaltropsGuide.tscn")
var laser_scene = preload("res://OnFootAssets/Player/Build/LaserWall.tscn")
var laser_guide_scene = preload("res://OnFootAssets/Player/Build/LaserGuide.tscn")
var guide_frame_tilemap
var wall_tilemap
var wall_tilemap_guide
var floor_tilemap
var floor_tilemap_guide
var landmine_guide
var caltrops_guide
var laser_guide

func update_buildings_from_saved_data():
	guide_frame_tilemap = guide_frame.instance()
	get_tree().get_root().call_deferred("add_child",guide_frame_tilemap)
	guide_frame_tilemap.modulate.a = .5
	
	floor_tilemap = floor_scene.instance()
	get_tree().get_root().call_deferred("add_child",floor_tilemap)
	floor_tilemap_guide = floor_scene.instance()
	get_tree().get_root().call_deferred("add_child",floor_tilemap_guide)
	floor_tilemap_guide.modulate.a = .5
	
	wall_tilemap = wall_scene.instance()
	get_tree().get_root().call_deferred("add_child",wall_tilemap)
	wall_tilemap_guide = wall_guide_scene.instance()
	get_tree().get_root().call_deferred("add_child",wall_tilemap_guide)
	wall_tilemap_guide.modulate.a = .5
	
	landmine_guide = landmine_guide_scene.instance()
	get_tree().get_root().call_deferred("add_child",landmine_guide)
	landmine_guide.modulate.a = .5
	landmine_guide.visible = false
	
	caltrops_guide = caltrops_guide_scene.instance()
	get_tree().get_root().call_deferred("add_child",caltrops_guide)
	caltrops_guide.modulate.a = .5
	caltrops_guide.visible = false
	
	laser_guide = laser_guide_scene.instance()
	get_tree().get_root().call_deferred("add_child",laser_guide)
	laser_guide.modulate.a = .5
	laser_guide.visible = false
	
	for building_type in planet_building_data:
		match building_type:
			building_types.WALL:
				for location in planet_building_data[building_type]:
					wall_tilemap.set_cell(location.x/tile_size,location.y/tile_size,0)
					wall_tilemap.update_bitmask_area(location/Vector2(tile_size,tile_size))
			building_types.FLOOR:
				for location in planet_building_data[building_type]:
					floor_tilemap.set_cell(location.x/tile_size,location.y/tile_size,0)
					floor_tilemap.update_bitmask_area(location/Vector2(tile_size,tile_size))
			building_types.LANDMINE:
				for location in planet_building_data[building_type]:
					var landmine = landmine_scene.instance()
					landmine.global_position = location
					landmine.mines = planet_building_data[building_type][location]
					get_tree().get_root().call_deferred("add_child",landmine)
			building_types.CALTROPS:
				for location in planet_building_data[building_type]:
					var caltrops = caltrops_scene.instance()
					caltrops.global_position = location
					var sprite = caltrops.get_node("Sprite")
					sprite.rotation = planet_building_data[building_type][location][0]
					sprite.flip_h = planet_building_data[building_type][location][1]
					sprite.flip_v = planet_building_data[building_type][location][2]
					get_tree().get_root().call_deferred("add_child",caltrops)
			building_types.LASER:
				for location in planet_building_data[building_type]:
					var laser = laser_scene.instance()
					laser.global_position = location
					laser.rotation = planet_building_data[building_type][location][0]
					laser.active = planet_building_data[building_type][location][1]
					get_tree().get_root().call_deferred("add_child",laser)

# building types

var current_building_type = ConstantsHolder.building_types.FLOOR
var last_mousepos = Vector2(0,0)
var building_types = ConstantsHolder.building_types

func build_state(delta):
	planet_building_data = GalaxySave.get_planet_building_data()
	var mousepos = get_global_mouse_position()
	var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, floor(mousepos.y/tile_size)*tile_size)
	if mousepos_floored != last_mousepos:
		last_mousepos = mousepos_floored
		update_guides(mousepos_floored)
	
	if Input.is_action_just_pressed("attack"):
		var placing_block_location = Vector2(floor(mousepos.x/tile_size)*tile_size, floor(mousepos.y/tile_size)*tile_size)
		match current_building_type:
			building_types.WALL:
				if not current_building_type in planet_building_data:
					planet_building_data[current_building_type] = []
				if not planet_building_data[current_building_type].has(placing_block_location):
					planet_building_data[current_building_type].append(placing_block_location)
					wall_tilemap.set_cell(placing_block_location.x/tile_size,placing_block_location.y/tile_size,0)
					wall_tilemap.update_bitmask_area(placing_block_location/Vector2(tile_size,tile_size))
			building_types.FLOOR:
				if not current_building_type in planet_building_data:
					planet_building_data[current_building_type] = []
				if not planet_building_data[current_building_type].has(placing_block_location):
					planet_building_data[current_building_type].append(placing_block_location)
					floor_tilemap.set_cell(placing_block_location.x/tile_size,placing_block_location.y/tile_size,0)
					floor_tilemap.update_bitmask_area(placing_block_location/Vector2(tile_size,tile_size))
			building_types.LANDMINE:
				if not current_building_type in planet_building_data:
					planet_building_data[current_building_type] = {}
				if not planet_building_data[current_building_type].has(placing_block_location):
					planet_building_data[current_building_type][placing_block_location] = 1
					var landmine = landmine_scene.instance()
					landmine.global_position = placing_block_location
					get_tree().get_root().call_deferred("add_child",landmine)
				elif planet_building_data[current_building_type][placing_block_location] < 3:
					planet_building_data[current_building_type][placing_block_location] += 1
					var possible_landmines = get_tree().get_nodes_in_group("Landmines")
					var found_landmine = false
					for candidate_landmine in possible_landmines:
						if candidate_landmine.global_position == placing_block_location:
							found_landmine = true
							candidate_landmine.mines += 1
			building_types.CALTROPS:
				if not current_building_type in planet_building_data:
					planet_building_data[current_building_type] = {}
				if not planet_building_data[current_building_type].has(placing_block_location):
					var caltrops = caltrops_scene.instance()
					caltrops.global_position = placing_block_location
					planet_building_data[current_building_type][placing_block_location] = randomize_orientation(caltrops.get_node("Sprite"))
					get_tree().get_root().call_deferred("add_child",caltrops)
			building_types.LASER:
				if not current_building_type in planet_building_data:
					planet_building_data[current_building_type] = {}
				if not planet_building_data[current_building_type].has(placing_block_location):
					var laser = laser_scene.instance()
					laser.global_position = placing_block_location
					var laser_rotation = 0
					var laser_active_state = true
					planet_building_data[current_building_type][placing_block_location] = [laser_rotation,laser_active_state] #rotation
					get_tree().get_root().call_deferred("add_child",laser)
					
		GalaxySave.set_building_data(planet_building_data)
		GalaxySave.save_data()
				
	if Input.is_action_just_pressed("harvest"):
		match current_building_type:
			building_types.WALL:
				if planet_building_data[current_building_type].has(mousepos_floored):
					planet_building_data[current_building_type].erase(mousepos_floored)
					wall_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,-1)
					wall_tilemap.update_bitmask_area(mousepos_floored/Vector2(tile_size,tile_size))
			building_types.FLOOR:
				if planet_building_data[current_building_type].has(mousepos_floored):
					planet_building_data[current_building_type].erase(mousepos_floored)
					floor_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,-1)
					floor_tilemap.update_bitmask_area(mousepos_floored/Vector2(tile_size,tile_size))
			building_types.LANDMINE:
				if planet_building_data[current_building_type].has(mousepos_floored):
					planet_building_data[current_building_type][mousepos_floored] -= 1
					var possible_landmines = get_tree().get_nodes_in_group("Landmines")
					for candidate_landmine in possible_landmines:
						if candidate_landmine.global_position == mousepos_floored:
							candidate_landmine.mines -= 1
							if planet_building_data[current_building_type][mousepos_floored] == 0:
								candidate_landmine.queue_free()
								planet_building_data[current_building_type].erase(mousepos_floored)
			building_types.CALTROPS:
				if planet_building_data[current_building_type].has(mousepos_floored):
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_caltrops = get_tree().get_nodes_in_group("Caltrops")
					for candidate_caltrops in possible_caltrops:
						if candidate_caltrops.global_position == mousepos_floored:
							candidate_caltrops.queue_free()
			building_types.LASER:
				if planet_building_data[current_building_type].has(mousepos_floored):
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_lasers = get_tree().get_nodes_in_group("Lasers")
					for candidate_lasers in possible_lasers:
						if candidate_lasers.global_position == mousepos_floored:
							candidate_lasers.queue_free()
			
		GalaxySave.set_building_data(planet_building_data)
		GalaxySave.save_data()
func update_guides(mousepos_floored):
	clear_all_guides()
	
	match current_building_type:
		building_types.WALL:
			wall_tilemap_guide.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,0)
		building_types.FLOOR:
			floor_tilemap_guide.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,0,false,false,false,Vector2(9,3))
			guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,0)
		building_types.LANDMINE:
			landmine_guide.visible = true
			landmine_guide.global_position = mousepos_floored
			guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,0)
		building_types.CALTROPS:
			caltrops_guide.visible = true
			caltrops_guide.global_position = mousepos_floored
			guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size,0)
		building_types.LASER:
			laser_guide.visible = true
			laser_guide.global_position = mousepos_floored

func clear_all_guides():
	wall_tilemap_guide.clear()
	floor_tilemap_guide.clear()
	landmine_guide.visible = false
	caltrops_guide.visible = false
	laser_guide.visible = false
	guide_frame_tilemap.clear()

func randomize_orientation(sprite):
	sprite.rotation = deg2rad(90 * (randi()%3))
	var bools = [true,false]
	sprite.flip_h = bools[randi()%2]
	sprite.flip_v = bools[randi()%2]
	return [sprite.rotation,sprite.flip_h,sprite.flip_v]
