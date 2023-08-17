extends KinematicBody2D

## MOVEMENT VARIABLES ##

var current_velocity := Vector2()
var input_velocity : Vector2 = Vector2()
var direction : Vector2 = Vector2()
export var movementSpeed = 70
export var isInRoom = false
export var slipperyGround = false
export var frozenPlanet = false
export var cutscene = []
export var testWorld = false
var recent_vectors = []
var isOnIce = false

### 

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var weaponHitbox = $HitboxPivot/WeaponHitbox
onready var hurtbox = $Hurtbox
	
# Control cutscene 
func add_cutscene(value):
	cutscene.append(value)
	SignalBus.emit_signal("cutscene_edited")
func remove_cutscene(value):
	for instance in cutscene.count(value):
		cutscene.erase(value)
	SignalBus.emit_signal("cutscene_edited")
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

signal teleported(direction)
func _ready():
	if GalaxySave.game_data["gameModifications"]["speedDemon"]:
		movementSpeed *= 3
	if GalaxySave.game_data["gameModifications"]["glassCannon"]:
		$HitboxPivot/WeaponHitbox.damage = 50
	$Camera2D.zoom = Vector2(.2,.2)
	$HitboxPivot.visible = true
	stats.connect("no_health",self,"on_death")
	animationTree.active = true
#	weaponHitbox.knockback_vector
	update_buildings_from_saved_data()

func _physics_process(delta):
	if cutscene.size() == 0:
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
			emit_signal("teleported",Vector2(1,0))
		elif self.global_position.x > map_size:
			self.global_position.x -= map_size
			emit_signal("teleported",Vector2(-1,0))
		if self.global_position.y < 0:
			self.global_position.y += map_size
			emit_signal("teleported",Vector2(0,-1))
		elif self.global_position.y > map_size:
			self.global_position.y -= map_size
			emit_signal("teleported",Vector2(0,1))
	
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
				if GalaxySave.game_data["storyProgression"] > 21:
					if current_building_type > building_types.size()-1:
						current_building_type = 0
				else:
					if current_building_type > building_types.size()-4:
						current_building_type = 0
				var mousepos = get_global_mouse_position()
				var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, ceil(mousepos.y/tile_size)*tile_size)
				update_guides(mousepos_floored)
	elif Input.is_action_just_released("weapon_switch_up"):
		match state:
			MOVE:
				weapon -= 1
				if weapon < 0:
					weapon = player_weapons.size()-1
			BUILD:
				current_building_type -= 1
				if current_building_type < 0:
					if GalaxySave.game_data["storyProgression"] > 21:
						current_building_type = building_types.size()-1
					else:
						current_building_type = building_types.size()-4
				var mousepos = get_global_mouse_position()
				var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, ceil(mousepos.y/tile_size)*tile_size)
				update_guides(mousepos_floored)
	
	# building
	if Input.is_action_just_pressed("build_state_switch"):
		print(state)
		if not isInRoom or testWorld:
			if state == MOVE:
				state = BUILD
				var mousepos = get_global_mouse_position()
				var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, ceil(mousepos.y/tile_size)*tile_size)
				update_guides(mousepos_floored)
			elif state == BUILD:
				state = MOVE
				clear_all_guides()
	
	# detecting attacks
	if Input.is_action_just_pressed("attack") and state == MOVE:
		match weapon:
			player_weapons.NEEDLE:
				AudioManager.play_effect([AudioManager.effects.needle])
				print("attack started")
				$AttackTree.set("parameters/Seek/seek_position",0)
				state = ATTACK
				weaponHitbox.harvesting_tool = false
				$AttackTree.active = true
				yield(get_tree().create_timer(.65), "timeout")
				attack_animation_finished2()
			player_weapons.NETGUN:
				AudioManager.play_effect([AudioManager.effects.net])
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
		AudioManager.play_effect([AudioManager.effects.needle])
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

var snow_footsteps = preload("res://Audio/Footsteps/snow_footsteps.wav")
var ice_footsteps = preload("res://Audio/Footsteps/ground_footsteps.wav")
func check_for_ice():
	var grass_tilemap = get_node("../../Grass")
	var playerPos = Vector2(grass_tilemap.world_to_map(global_position).x,grass_tilemap.world_to_map(global_position+Vector2(0,5)).y)
	var playerPos2 = Vector2(grass_tilemap.world_to_map(global_position+Vector2(8,0)).x,grass_tilemap.world_to_map(global_position+Vector2(0,-2)).y)
	if grass_tilemap.get_cell(playerPos.x,playerPos.y) == -1 or grass_tilemap.get_cell(playerPos2.x,playerPos2.y) == -1 :
		footstepAudio.stream = ice_footsteps
		return true
	else:
		footstepAudio.stream = snow_footsteps
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
	$DeathTree.set("parameters/blend_position",target_velocity)

onready var footstepAudio = $FootstepAudio
func play_footstep_sound():
	var newPlayer = AudioStreamPlayer.new()
	newPlayer.volume_db = footstepAudio.volume_db
	newPlayer.pitch_scale = footstepAudio.pitch_scale
	newPlayer.stream = footstepAudio.stream
	add_child(newPlayer)
	newPlayer.play()
	newPlayer.connect("finished",newPlayer,"queue_free")
	
## ATTACKING ##

func attack_state(_delta):
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
		pass
	else:
		yield(get_tree().create_timer(weaponHitbox.harvest_wait_time), "timeout")
	weaponHitbox.harvesting_tool = false
	play_animation($AttackTree)
	print("harvest finished")
	state = ATTACK

func harvest_end():
	$AttackTree.active = false
	needle_attack_with_netgun_equipped = false
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if area.get("damage"):
		stats.health -= area.damage
		hurtbox.start_invincibility(0.5)
		hurtbox.create_hit_effect()
		GalaxySave.game_data["playerHealth"] = stats.health
		print("player save stats:")
		print(GalaxySave.game_data)
		GalaxySave.save_data()

func pause_animation(player,time_position):
	player.set("parameters/TimeScale/scale",0)
	$AttackTree.set("parameters/Seek/seek_position",time_position)
func play_animation(player):
	player.set("parameters/TimeScale/scale",1)

## Attacking With Netgun ##

func attack_state_NETGUN(_delta):
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
		get_parent().add_child(projectile)
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
var turret_scene = preload("res://OnFootAssets/Player/Build/Turret.tscn")
var turret_guide_scene = preload("res://OnFootAssets/Player/Build/TurretGuide.tscn")
var capturer_scene = preload("res://OnFootAssets/Player/Build/Capturer.tscn")
var capturer_guide_scene = preload("res://OnFootAssets/Player/Build/CapturerGuide.tscn")
var cannon_base_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonBase.tscn")
var cannon_base_guide_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonBaseGuide.tscn")
var cannon_turret_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonTurret.tscn")
var cannon_turret_guide_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonTurretGuide.tscn")
var cannon_power_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonPower.tscn")
var cannon_power_guide_scene = preload("res://OnFootAssets/Player/Build/Cannon/CannonPowerGuide.tscn")
var guide_frame_tilemap
var wall_tilemap
var wall_tilemap_guide
var floor_tilemap
var floor_tilemap_guide
var landmine_guide
var caltrops_guide
var laser_guide
var turret_guide
var capturer_guide
var cannon_base_guide
var cannon_turret_guide
var cannon_power_guide
onready var YSorting_Node = get_node("..")

func update_buildings_from_saved_data():
	guide_frame_tilemap = guide_frame.instance()
	root_building_holder.call_deferred("add_child",guide_frame_tilemap)
	guide_frame_tilemap.modulate.a = .5
	
	floor_tilemap = floor_scene.instance()
	YSorting_Node.call_deferred("add_child",floor_tilemap)
	floor_tilemap_guide = floor_scene.instance()
	root_building_holder.call_deferred("add_child",floor_tilemap_guide)
	floor_tilemap_guide.modulate.a = .5
	
	wall_tilemap = wall_scene.instance()
	YSorting_Node.call_deferred("add_child",wall_tilemap)
	wall_tilemap_guide = wall_guide_scene.instance()
	root_building_holder.call_deferred("add_child",wall_tilemap_guide)
	wall_tilemap_guide.modulate.a = .5
	
	landmine_guide = landmine_guide_scene.instance()
	root_building_holder.call_deferred("add_child",landmine_guide)
	landmine_guide.modulate.a = .5
	landmine_guide.visible = false
	
	caltrops_guide = caltrops_guide_scene.instance()
	root_building_holder.call_deferred("add_child",caltrops_guide)
	caltrops_guide.modulate.a = .5
	caltrops_guide.visible = false
	
	laser_guide = laser_guide_scene.instance()
	root_building_holder.call_deferred("add_child",laser_guide)
	laser_guide.modulate.a = .5
	laser_guide.visible = false
	
	turret_guide = turret_guide_scene.instance()
	root_building_holder.call_deferred("add_child",turret_guide)
	turret_guide.modulate.a = .5
	turret_guide.visible = false
	
	capturer_guide = capturer_guide_scene.instance()
	root_building_holder.call_deferred("add_child",capturer_guide)
	capturer_guide.modulate.a = .5
	capturer_guide.visible = false
	
	cannon_base_guide = cannon_base_guide_scene.instance()
	root_building_holder.call_deferred("add_child",cannon_base_guide)
	cannon_base_guide.modulate.a = .5
	cannon_base_guide.visible = false
	
	cannon_turret_guide = cannon_turret_guide_scene.instance()
	root_building_holder.call_deferred("add_child",cannon_turret_guide)
	cannon_turret_guide.modulate.a = .5
	cannon_turret_guide.visible = false
	
	cannon_power_guide = cannon_power_guide_scene.instance()
	root_building_holder.call_deferred("add_child",cannon_power_guide)
	cannon_power_guide.modulate.a = .5
	cannon_power_guide.visible = false
	
	var cannon_turret_placed_instance = null
	for building_type in planet_building_data:
		match building_type:
			building_types.WALL:
				for location in planet_building_data[building_type]:
					wall_tilemap.set_cell(location.x/tile_size,location.y/tile_size-1,0)
					wall_tilemap.update_bitmask_area(location/Vector2(tile_size,tile_size)-Vector2(0,1))
			building_types.FLOOR:
				for location in planet_building_data[building_type]:
					floor_tilemap.set_cell(location.x/tile_size,location.y/tile_size-1,0)
					floor_tilemap.update_bitmask_area(location/Vector2(tile_size,tile_size)-Vector2(0,1))
			building_types.LANDMINE:
				for location in planet_building_data[building_type]:
					var landmine = landmine_scene.instance()
					landmine.global_position = location
					landmine.mines = planet_building_data[building_type][location]
					root_building_holder.call_deferred("add_child",landmine)
					var ysort_pos = YSorting_Node.get_index()
					root_building_holder.call_deferred("move_child",landmine,ysort_pos)
			building_types.CALTROPS:
				for location in planet_building_data[building_type]:
					var caltrops = caltrops_scene.instance()
					caltrops.global_position = location
					var sprite = caltrops.get_node("SpriteHolder/Sprite")
					sprite.rotation = planet_building_data[building_type][location][0]
					sprite.flip_h = planet_building_data[building_type][location][1]
					sprite.flip_v = planet_building_data[building_type][location][2]
					root_building_holder.call_deferred("add_child",caltrops)
					var ysort_pos = YSorting_Node.get_index()
					root_building_holder.call_deferred("move_child",caltrops,ysort_pos)
			building_types.LASER:
				for location in planet_building_data[building_type]:
					var laser = laser_scene.instance()
					laser.global_position = location
					laser.alignment_HV = planet_building_data[building_type][location][0]
					laser.active = planet_building_data[building_type][location][1]
					YSorting_Node.call_deferred("add_child",laser)
			building_types.TURRET:
				for location in planet_building_data[building_type]:
					var turret = turret_scene.instance()
					turret.global_position = location
					YSorting_Node.call_deferred("add_child",turret)
			building_types.CAPTURER:
				for location in planet_building_data[building_type]:
					var capturer = capturer_scene.instance()
					capturer.global_position = location
					YSorting_Node.call_deferred("add_child",capturer)
			building_types.CANNONBASE:
				for location in planet_building_data[building_type]:
					var cannon_base = cannon_base_scene.instance()
					cannon_base.global_position = location-Vector2(0,tile_size)
					root_building_holder.call_deferred("add_child",cannon_base)
					var ysort_pos = YSorting_Node.get_index()
					root_building_holder.call_deferred("move_child",cannon_base,ysort_pos)
			building_types.CANNONTURRET:
				for location in planet_building_data[building_type]:
					var cannon_turret = cannon_turret_scene.instance()
					cannon_turret_placed_instance = cannon_turret
					cannon_turret.global_position = location
					YSorting_Node.call_deferred("add_child",cannon_turret)
			building_types.CANNONPOWER:
				for location in planet_building_data[building_type]:
					var cannon_power = cannon_power_scene.instance()
					cannon_turret_placed_instance.call_deferred("add_child",cannon_power)

# building types

var current_building_type = ConstantsHolder.building_types.FLOOR
var last_mousepos = Vector2(0,0)
var building_types = ConstantsHolder.building_types
onready var root_building_holder = YSorting_Node.get_parent()
func add_to_root_building_holder(nodeToUse):
	root_building_holder.call_deferred("add_child",nodeToUse)
	root_building_holder.call_deferred("move_child",nodeToUse,YSorting_Node.get_index())

func build_state(_delta):
	planet_building_data = GalaxySave.get_planet_building_data()
	var mousepos = get_global_mouse_position()
	var mousepos_floored = Vector2(floor(mousepos.x/tile_size)*tile_size, ceil(mousepos.y/tile_size)*tile_size)
	if mousepos_floored != last_mousepos or current_velocity != Vector2.ZERO:
		last_mousepos = mousepos_floored
		update_guides(mousepos_floored)
	
	if Input.is_action_just_pressed("attack"):
		var placing_block_location = Vector2(floor(mousepos.x/tile_size)*tile_size, ceil(mousepos.y/tile_size)*tile_size)
		if can_afford_building():
			AudioManager.play_effect([AudioManager.effects.placement1,AudioManager.effects.placement2,AudioManager.effects.placement3])
			match current_building_type:
				building_types.WALL:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						planet_building_data[current_building_type].append(placing_block_location)
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						wall_tilemap.set_cell(placing_block_location.x/tile_size,placing_block_location.y/tile_size-1,0)
						wall_tilemap.update_bitmask_area(placing_block_location/Vector2(tile_size,tile_size)-Vector2(0,1))
				building_types.FLOOR:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						planet_building_data[current_building_type].append(placing_block_location)
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						floor_tilemap.set_cell(placing_block_location.x/tile_size,placing_block_location.y/tile_size-1,0)
						floor_tilemap.update_bitmask_area(placing_block_location/Vector2(tile_size,tile_size)-Vector2(0,1))
				building_types.LANDMINE:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = {}
					if not planet_building_data[current_building_type].has(placing_block_location):
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						planet_building_data[current_building_type][placing_block_location] = 1
						var landmine = landmine_scene.instance()
						landmine.global_position = placing_block_location
						add_to_root_building_holder(landmine)
					elif planet_building_data[current_building_type][placing_block_location] < 3:
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						planet_building_data[current_building_type][placing_block_location] += 1
						var possible_landmines = get_tree().get_nodes_in_group("Landmines")
						#warning-ignore:unused_variable
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
						planet_building_data[current_building_type][placing_block_location] = randomize_orientation(caltrops.get_node("SpriteHolder/Sprite"))
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						add_to_root_building_holder(caltrops)
				building_types.LASER:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = {}
					if not planet_building_data[current_building_type].has(placing_block_location) and check_side_availability(planet_building_data[current_building_type],placing_block_location):
						var laser = laser_scene.instance()
						laser.global_position = placing_block_location
						laser.alignment_HV = direction_to_bool()
						var laser_rotation = direction_to_bool()
						var laser_active_state = true
						planet_building_data[current_building_type][placing_block_location] = [laser_rotation,laser_active_state] #rotation
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						YSorting_Node.call_deferred("add_child",laser)
				building_types.TURRET:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						planet_building_data[current_building_type].append(placing_block_location)
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						var turret = turret_scene.instance()
						turret.global_position = placing_block_location
						YSorting_Node.call_deferred("add_child",turret)
				building_types.CAPTURER:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						planet_building_data[current_building_type].append(placing_block_location)
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						var capturer = capturer_scene.instance()
						capturer.global_position = placing_block_location
						YSorting_Node.call_deferred("add_child",capturer)
				building_types.CANNONBASE:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						planet_building_data[current_building_type].append(placing_block_location)
						GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
						var cannon_base = cannon_base_scene.instance()
						cannon_base.global_position = placing_block_location-Vector2(0,tile_size)
						add_to_root_building_holder(cannon_base)
				building_types.CANNONTURRET:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not building_types.CANNONBASE in planet_building_data:
						planet_building_data[building_types.CANNONBASE] = []
					if not planet_building_data[current_building_type].has(placing_block_location):
						if planet_building_data[building_types.CANNONBASE].size() > 0:
							var turret_placement_location = planet_building_data[building_types.CANNONBASE][0] + Vector2(192,16)
							if turret_placement_location.distance_to(placing_block_location) < tile_size*5:
								planet_building_data[current_building_type].append(turret_placement_location)
								GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
								var cannon_turret = cannon_turret_scene.instance()
								cannon_turret.global_position = turret_placement_location
								YSorting_Node.call_deferred("add_child",cannon_turret)
				building_types.CANNONPOWER:
					if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
					if not building_types.CANNONBASE in planet_building_data:
						planet_building_data[building_types.CANNONBASE] = []
					if not building_types.CANNONTURRET in planet_building_data:
						planet_building_data[building_types.CANNONTURRET] = []
					if planet_building_data[building_types.CANNONBASE].size() > 0 and planet_building_data[building_types.CANNONTURRET].size() > 0:
						var power_placement_location = planet_building_data[building_types.CANNONTURRET][0] + Vector2(-37,-10)
						if power_placement_location.distance_to(placing_block_location) < tile_size*5:
							planet_building_data[current_building_type].append(0)
							GalaxySave.game_data["storedBuildings"][current_building_type] -= 1
							var cannon_power = cannon_power_scene.instance()
							var turret_placed_instance = get_tree().get_nodes_in_group("Cannon_Turret")[0]
							turret_placed_instance.call_deferred("add_child",cannon_power)
							GalaxySave.game_data["cannonLocation"] = GalaxySave.game_data["shipPosition"][0]
			GalaxySave.set_building_data(planet_building_data)
			GalaxySave.save_data()
				
	if Input.is_action_just_pressed("harvest"):
		match current_building_type:
			building_types.WALL:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					wall_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,-1)
					wall_tilemap.update_bitmask_area(mousepos_floored/Vector2(tile_size,tile_size)-Vector2(0,1))
					GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.FLOOR:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					floor_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,-1)
					floor_tilemap.update_bitmask_area(mousepos_floored/Vector2(tile_size,tile_size)-Vector2(0,1))
					GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.LANDMINE:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = {}
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type][mousepos_floored] -= 1
					var possible_landmines = get_tree().get_nodes_in_group("Landmines")
					for candidate_landmine in possible_landmines:
						if candidate_landmine.global_position == mousepos_floored:
							candidate_landmine.mines -= 1
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.CALTROPS:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = {}
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_caltrops = get_tree().get_nodes_in_group("Caltrops")
					for candidate_caltrops in possible_caltrops:
						if candidate_caltrops.global_position == mousepos_floored:
							candidate_caltrops.queue_free()
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.LASER:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = {}
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_lasers = get_tree().get_nodes_in_group("Lasers")
					for candidate_lasers in possible_lasers:
						if candidate_lasers.global_position == mousepos_floored:
							candidate_lasers.queue_free()
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.TURRET:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_turrets = get_tree().get_nodes_in_group("Turrets")
					for candidate_turrets in possible_turrets:
						if candidate_turrets.global_position == mousepos_floored:
							candidate_turrets.queue_free()
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.CAPTURER:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_capturers = get_tree().get_nodes_in_group("Capturers")
					for candidate_capturers in possible_capturers:
						if candidate_capturers.global_position == mousepos_floored:
							candidate_capturers.queue_free()
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.CANNONBASE:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if not building_types.CANNONTURRET in planet_building_data:
						planet_building_data[building_types.CANNONTURRET] = []
				if planet_building_data[current_building_type].has(mousepos_floored) and planet_building_data[building_types.CANNONTURRET].size() == 0:
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(mousepos_floored)
					var possible_bases = get_tree().get_nodes_in_group("Cannon_Base")
					for candidate_bases in possible_bases:
						if candidate_bases.global_position == mousepos_floored-Vector2(0,tile_size):
							candidate_bases.queue_free()
							GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.CANNONTURRET:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if not building_types.CANNONPOWER in planet_building_data:
					planet_building_data[building_types.CANNONPOWER] = []
				if planet_building_data[current_building_type].has(mousepos_floored):
					AudioManager.play_effect([AudioManager.effects.breakage])
					if planet_building_data[building_types.CANNONPOWER].size() == 0:
						planet_building_data[current_building_type].erase(mousepos_floored)
						var possible_bases = get_tree().get_nodes_in_group("Cannon_Turret")
						for candidate_bases in possible_bases:
							if candidate_bases.global_position == mousepos_floored:
								candidate_bases.queue_free()
								GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			building_types.CANNONPOWER:
				if not current_building_type in planet_building_data:
						planet_building_data[current_building_type] = []
				if planet_building_data[current_building_type].has(0) and ConstantsHolder.cannon_moveable:
					AudioManager.play_effect([AudioManager.effects.breakage])
					planet_building_data[current_building_type].erase(0)
					var possible_bases = get_tree().get_nodes_in_group("Cannon_Power")
					for candidate_bases in possible_bases:
						candidate_bases.queue_free()
						GalaxySave.game_data["storedBuildings"][current_building_type] += 1
			
		GalaxySave.set_building_data(planet_building_data)
		GalaxySave.save_data()
func update_guides(mousepos_floored):
	clear_all_guides()
	if state == BUILD:
		match current_building_type:
			building_types.WALL:
				wall_tilemap_guide.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.FLOOR:
				floor_tilemap_guide.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0,false,false,false,Vector2(9,3))
				guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.LANDMINE:
				landmine_guide.visible = true
				landmine_guide.global_position = mousepos_floored
				guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.CALTROPS:
				caltrops_guide.visible = true
				caltrops_guide.global_position = mousepos_floored
				guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.LASER:
				laser_guide.visible = true
				laser_guide.alignment_HV = direction_to_bool()
				laser_guide.global_position = mousepos_floored
			building_types.TURRET:
				turret_guide.visible = true
				turret_guide.global_position = mousepos_floored
				guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.CAPTURER:
				capturer_guide.visible = true
				capturer_guide.global_position = mousepos_floored
				guide_frame_tilemap.set_cell(mousepos_floored.x/tile_size,mousepos_floored.y/tile_size-1,0)
			building_types.CANNONBASE:
				cannon_base_guide.visible = true
				cannon_base_guide.global_position = mousepos_floored-Vector2(0,tile_size)
			building_types.CANNONTURRET:
				cannon_turret_guide.visible = true
				cannon_turret_guide.global_position = mousepos_floored
			building_types.CANNONPOWER:
				cannon_power_guide.visible = true
				cannon_power_guide.global_position = mousepos_floored

func clear_all_guides():
	wall_tilemap_guide.clear()
	floor_tilemap_guide.clear()
	landmine_guide.visible = false
	caltrops_guide.visible = false
	laser_guide.visible = false
	turret_guide.visible = false
	capturer_guide.visible = false
	cannon_base_guide.visible = false
	cannon_turret_guide.visible = false
	cannon_power_guide.visible = false
	guide_frame_tilemap.clear()

func randomize_orientation(sprite):
	sprite.rotation = deg2rad(90 * (randi()%3))
	var bools = [true,false]
	sprite.flip_h = bools[randi()%2]
	sprite.flip_v = bools[randi()%2]
	return [sprite.rotation,sprite.flip_h,sprite.flip_v]

func get_last_direction_moved():
	return animationTree.get("parameters/Run/blend_position")

func direction_to_bool(): # horizontal is true
	var nearest = stepify(get_last_direction_moved().angle()-PI/2,PI/4)
	if int(nearest)%int(PI) == 0:
		return true
	elif int(nearest/(PI/4))%2 != 0:
		return true
	else:
		return false

func check_side_availability(dictionary_of_positions,placing_position):
	var HV = direction_to_bool()
	var sides = []
	var horizontal_to_check = [Vector2(16,0),Vector2(-16,0)]
	var vertical_to_check = [Vector2(0,16),Vector2(0,-16)]
	if HV:
		sides.append(placing_position + Vector2(-16,0))
		sides.append(placing_position + Vector2(16,0))
	else:
		sides.append(placing_position + Vector2(0,-16))
		sides.append(placing_position + Vector2(0,16))
	var site_approved = true
	for side_to_check in sides:
		if dictionary_of_positions.has(side_to_check):
			return false # site not approved
		for nearby_direction in horizontal_to_check:
			var modified_direction = side_to_check + nearby_direction
			if dictionary_of_positions.has(modified_direction):
				if dictionary_of_positions[modified_direction][0] == true:
					return false # site not approved
		for nearby_direction in vertical_to_check:
			var modified_direction = side_to_check + nearby_direction
			if dictionary_of_positions.has(modified_direction):
				if dictionary_of_positions[modified_direction][0] == false:
					return false # site not approved
	for location_to_check in horizontal_to_check:
		var modified_PL = placing_position + location_to_check
		if dictionary_of_positions.has(modified_PL):
			return false # site not approved
	return site_approved

func can_afford_building():
	if GalaxySave.game_data["storedBuildings"][current_building_type] > 0:
		return true
	else:
		return false

## Death ##

onready var player_sprite = $BackBufferCopy/Sprite
onready var death_animation_tree = $DeathTree
var dead_check = false
var netgun_out = false
func on_death():
	if not dead_check:
		# death animation
		dead_check = true
		death_animation_tree.active = true
		animationTree.active = false
		add_cutscene("death")
		# drop carried loot
		for key in GalaxySave.game_data["backpackBlood"]:
			GalaxySave.game_data["backpackBlood"][key] = 0
		# fade to inside ship
		# respawn at respawner with effect
		ConstantsHolder.respawning = true
		PlayerStats.health = PlayerStats.max_health
		yield(get_tree().create_timer(2.0), "timeout")
		var _change = get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
		GalaxySave.save_data()
		
