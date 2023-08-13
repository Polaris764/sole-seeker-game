extends Node2D

export var homing_bullets_line = 500
export var player : NodePath
onready var playerNode = get_node(player)
var bullet = preload("res://OnFootAssets/Village/VillageBullet.tscn")
func _ready():
	AudioManager.play_song([AudioManager.songs.rest],"village")
	GalaxySave.game_data["shipPosition"][4] = ConstantsHolder.ship_locations.STATION
	GalaxySave.game_data["shipPosition"][2] = -2
	set_up_terrain()
	start_events()
func _exit_tree():
	AudioManager.stop_song("village")
onready var grass = $Grass
onready var fenceLength = $YSort/FenceLength
onready var fenceWidth = $YSort/FenceWidth

func set_up_terrain():
	var grass_array = grass.get_used_cells()
	for cell in grass_array:
		grass.set_cell(cell.x,cell.y,randi()%16,rand_bool(),rand_bool())
	var fence_array1 = fenceLength.get_used_cells()
	for cell in fence_array1:
		fenceLength.set_cell(cell.x,cell.y,randi()%8)
	var fence_array2 = fenceWidth.get_used_cells()
	for cell in fence_array2:
		fenceWidth.set_cell(cell.x,cell.y,randi()%16)

var kept_tiles = [0,1,2,3,4,134,135,136]
func destroy_fence():
	var fence_array = fenceWidth.get_used_cells()
	for cell in fence_array:
		if not cell.x in kept_tiles and cell.y == 30:
			fenceWidth.set_cell(cell.x,cell.y,-1)

func rand_bool():
	if randi()%2 == 0:
		return true
	else:
		return false

var rng = RandomNumberGenerator.new()
export var bullet_spread = .17
onready var bullet_positions = [$BulletOrigin1,$BulletOrigin2]
func _on_BulletTimer_timeout():
	$BulletTimer.start(randf()/2)
	if event_stage > 1: # shooting has started
		shoot_bullet()
		shoot_bullet()
		shoot_bullet()
		shoot_bullet()
		# spawn bullet at point
		# send to scripted location based on bullet number
		# reset bullet timer

func shoot_bullet():
	var bullet_instance = bullet.instance()
	AudioManager.play_effect([AudioManager.effects.turret])
	add_child(bullet_instance)
	bullet_instance.player = player
	if playerNode.global_position.y > homing_bullets_line:
		bullet_instance.homing_target = player
	bullet_instance.velocity = Vector2(rng.randf_range(-PI/2-bullet_spread,-PI/2+bullet_spread),0)
	bullet_instance.global_position = Vector2(rng.randi_range(bullet_positions[0].global_position.x,bullet_positions[1].global_position.x),bullet_positions[0].global_position.y)

# Event management

var event_stage = 0
export var shooting_start_time = 30
export var blackout_time = 30
onready var event_timer = $EventTimer
onready var playerCam = $ChildPlayerCamera
onready var villagers = $Villagers.get_children()

func start_events():
	event_timer.start(shooting_start_time)
	event_stage = 1

func _on_EventTimer_timeout():
	if event_stage == 1:
		print("shooting start")
		playerNode.set_panic()
		for villager in villagers:
			villager.set_panic(true)
		event_stage = 2
		event_timer.start(blackout_time)
		playerCam.add_trauma(.4)
		destroy_fence()
	elif event_stage == 2:
		print("blackout")
		var _change = get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
		
