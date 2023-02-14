extends Node2D

export var map_size = Vector2(200,200)
var map_side_size = map_size.x
var upper_cap = .45
var wet_cap = .4

# Generate high and low areas
# seperate high area into mossy and clear

func _ready():
	var rain = load("res://OnFootAssets/RainParticles.tscn").instance()
	$Player/Camera2D.add_child(rain)
	$Fog/Fog.rect_size = Vector2(16,16)*(map_size+Vector2(40,40))
	$Fog/Fog.rect_position = Vector2(16,16)*Vector2(-20,-20)
	$Player.slipperyGround = true
	get_node("..").ship_position = find_ship_pos()
	seed(GalaxySave.getLastPlanetClicked())
	make_lower_map()
	make_upper_map()
	refine_upper_map()

func make_lower_map():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var usedTile  = randi()%8
			$LowerStones.set_cell(x,y,usedTile)
			#set corners
			if x < 20 and y < 20:
				$LowerStones.set_cell(x+map_size.x,y+map_size.y,usedTile)
			elif x > map_size.x-20 and y > map_size.y-20:
				$LowerStones.set_cell(x-map_size.x,y-map_size.y,usedTile)
			elif x < 20 and y > map_size.y-20:
				$LowerStones.set_cell(x+map_size.x,y-map_size.y,usedTile)
			elif x > map_size.x-20 and y < 20:
				$LowerStones.set_cell(x-map_size.x,y+map_size.y,usedTile)
			#set sides
			if x < 20:
				$LowerStones.set_cell(x+map_size.x,y,usedTile)
			elif x > map_side_size-20:
				$LowerStones.set_cell(x-map_size.x,y,usedTile)
			if y < 20:
				$LowerStones.set_cell(x,y+map_size.y,usedTile)
			elif y > map_side_size-20:
				$LowerStones.set_cell(x,y-map_size.y,usedTile)

func make_upper_map():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12
	var noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			#get_node("..").ship_position = find_ship_pos()
			if a < upper_cap:
				$UpperStonesWet.set_cell(x,y,0)
				var autotileCoord = $UpperStonesWet.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 2 and y <= 2:
					$UpperStonesWet.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-2 and y >= map_size.y-2:
					$UpperStonesWet.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-2 and y <= 2:
					$UpperStonesWet.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x <= 2 and y >= map_size.y-2:
					$UpperStonesWet.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,autotileCoord)

				# set edge sides
				if x <= 2:
					$UpperStonesWet.set_cell(map_size.x+x,y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-2:
					$UpperStonesWet.set_cell(x-map_size.x,y,0,false,false,false,autotileCoord)
				if y <= 2:
					$UpperStonesWet.set_cell(x,map_size.y+y,0,false,false,false,autotileCoord)
				elif y >= map_size.y-2:
					$UpperStonesWet.set_cell(x,y-map_size.y,0,false,false,false,autotileCoord)
	$UpperStonesWet.update_bitmask_region(Vector2(-2,-2),Vector2(map_size.x+2,map_size.y+2))
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < upper_cap:
				var autotileCoord = $UpperStonesWet.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperStonesWet.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperStonesWet.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-20 and y <= 20:
					$UpperStonesWet.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x <= 20 and y >= map_size.y-20:
					$UpperStonesWet.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,autotileCoord)

				# set edge sides
				if x <= 20:
					$UpperStonesWet.set_cell(map_size.x+x,y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-21:
					$UpperStonesWet.set_cell(x-map_size.x,y,0,false,false,false,autotileCoord)
				if y <= 20:
					$UpperStonesWet.set_cell(x,map_size.y+y,0,false,false,false,autotileCoord)
				elif y >= map_size.y-21:
					$UpperStonesWet.set_cell(x,y-map_size.y,0,false,false,false,autotileCoord)
func refine_upper_map():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12
	var noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < wet_cap and $UpperStonesWet.get_cell(x,y) != -1:
				$UpperStonesDry.set_cell(x,y,0)
				# set edge corners
				if x <= 2 and y <= 2:
					$UpperStonesDry.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-2 and y >= map_size.y-2:
					$UpperStonesDry.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-2 and y <= 2:
					$UpperStonesDry.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 2 and y >= map_size.y-2:
					$UpperStonesDry.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 2:
					$UpperStonesDry.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-2:
					$UpperStonesDry.set_cell(x-map_size.x,y,0)
				if y <= 2:
					$UpperStonesDry.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-2:
					$UpperStonesDry.set_cell(x,y-map_size.y,0)
	$UpperStonesDry.update_bitmask_region(Vector2(-2,-2),Vector2(map_size.x+2,map_size.y+2))
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < wet_cap and $UpperStonesWet.get_cell(x,y) != -1:
				var autotileCoord = $UpperStonesDry.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperStonesDry.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperStonesDry.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-20 and y <= 20:
					$UpperStonesDry.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,autotileCoord)
				elif x <= 20 and y >= map_size.y-20:
					$UpperStonesDry.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,autotileCoord)

				# set edge sides
				if x <= 20:
					$UpperStonesDry.set_cell(map_size.x+x,y,0,false,false,false,autotileCoord)
				elif x >= map_size.x-21:
					$UpperStonesDry.set_cell(x-map_size.x,y,0,false,false,false,autotileCoord)
				if y <= 20:
					$UpperStonesDry.set_cell(x,map_size.y+y,0,false,false,false,autotileCoord)
				elif y >= map_size.y-21:
					$UpperStonesDry.set_cell(x,y-map_size.y,0,false,false,false,autotileCoord)
			
	
func find_ship_pos():
#	print("finding ship pos")
	return Vector2(1600,1600)
