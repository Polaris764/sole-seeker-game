extends Node2D

onready var grass = $Grass
onready var fenceLength = $YSort/FenceLength
onready var fenceWidth = $YSort/FenceWidth
onready var player = $YSort/Player
onready var spaceship = $Spaceship
onready var ship_shadow = $Shadow
export var map_side_size = 100
var rng = RandomNumberGenerator.new()

func _ready():
	set_up_terrain()
	if GalaxySave.game_data["shipPosition"][6]:
		player.queue_free()
		$VisitingCamera.global_position = spaceship.global_position
		$VisitingCamera.current = true
	else:
		player.global_position = spaceship.global_position + Vector2(83,37)
		send_ship()
func set_up_terrain():
	for tileX in map_side_size:
		for tileY in map_side_size:
			var cell_decal = randi()%16
			var bool1 = rand_bool()
			var bool2 = rand_bool()
			grass.set_cell(tileX,tileY,cell_decal,bool1,bool2)
			if tileX <= 20 and tileY <= 20:
				grass.set_cell(map_side_size+tileX,map_side_size+tileY,cell_decal,bool1,bool2)
			elif tileX >= map_side_size-20 and tileY >= map_side_size-20:
				grass.set_cell(tileX-map_side_size,tileY-map_side_size,cell_decal,bool1,bool2)
			elif tileX >= map_side_size-20 and tileY <= 20:
				grass.set_cell(tileX-map_side_size,map_side_size+tileY,cell_decal,bool1,bool2)
			elif tileX <= 20 and tileY >= map_side_size-20:
				grass.set_cell(map_side_size+tileX,tileY-map_side_size,cell_decal,bool1,bool2)
				
			if tileX <= 20:
				grass.set_cell(map_side_size+tileX,tileY,cell_decal,bool1,bool2)
			elif tileX >= map_side_size-21:
				grass.set_cell(tileX-map_side_size,tileY,cell_decal,bool1,bool2)
			if tileY <= 20:
				grass.set_cell(tileX,map_side_size+tileY,cell_decal,bool1,bool2)
			elif tileY >= map_side_size-21:
				grass.set_cell(tileX,tileY-map_side_size,cell_decal,bool1,bool2)

func rand_bool():
	if randi()%2 == 0:
		return true
	else:
		return false

onready var tween = $Tween
func send_ship():
	player.add_cutscene(name)
	tween.interpolate_property(spaceship,"scale",spaceship.scale,Vector2(1.5,1.5),3)
	tween.start()
	tween.interpolate_property(spaceship,"global_position",spaceship.global_position,spaceship.global_position+Vector2(0,-15*16),3)
	tween.start()
	tween.interpolate_property(ship_shadow,"scale",ship_shadow.scale,Vector2(0,0),6)
	tween.start()
	$ShipTimer.start()
func _on_ShipTimer_timeout():
	tween.interpolate_property(ship_shadow,"global_position",ship_shadow.global_position,ship_shadow.global_position+Vector2(25*16,0),5)
func _on_VisibilityNotifier2D_screen_exited():
	spaceship.queue_free()
	player.remove_cutscene(name)
