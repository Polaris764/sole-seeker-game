extends Node2D

var noise
export var map_side_size = 200
var map_size = Vector2(map_side_size,map_side_size)
var grass_cap = .45
var road_caps = Vector2(.4,.37)
var environment_caps = Vector3(.4,.3,.04)
var noiseImage

func _ready():
	
	seed(GalaxySave.getLastPlanetClicked())
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	make_grass_map()
	make_background()
	#make_road_map()

var lowestA = 1
func make_grass_map():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < lowestA and x > 20 and x < map_side_size-20 and  y > 20 and y < map_side_size-20:
				lowestA = a
				get_node("..").ship_position = Vector2(x*16,y*16)
			if a < grass_cap:
				$Rock.set_cell(x,y,0)
				# set edge corners
				if x <= 20 and y <= 20:
					$Rock.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$Rock.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-20 and y <= 20:
					$Rock.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 20 and y >= map_size.y-20:
					$Rock.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 20:
					$Rock.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-21:
					$Rock.set_cell(x-map_size.x,y,0)
				if y <= 20:
					$Rock.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-21:
					$Rock.set_cell(x,y-map_size.y,0)
			
	$Rock.update_bitmask_region(Vector2(-20,-20),Vector2(map_size.x+20,map_size.y+20))

func make_background():
	for x in map_size.x+40:
		for y in map_size.y+40:
			if $Rock.get_cell(x-20,y-20) == -1:
				$Lava.set_cell(x-20,y-20,0)
#
#func make_road_map():
#	for x in map_size.x:
#		for y in map_size.y:
#			var a = noiseImage.get_pixel(x,y).gray()
#			if a < road_caps.x and a > road_caps.y:
#				$Path.set_cell(x,y,0)
#	$Path.update_bitmask_region(Vector2(0,0),Vector2(map_size.x,map_size.y))
