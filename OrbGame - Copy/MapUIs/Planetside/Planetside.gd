extends Node2D

var noise
export var map_side_size = 80
var map_size = Vector2(map_side_size,map_side_size)
var grass_cap = .45
var road_caps = Vector2(.4,.37)
var environment_caps = Vector3(.4,.3,.04)
var noiseImage

func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = 1
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	#make_grass_map()
	#make_background()
	#make_road_map()

func make_grass_map():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < grass_cap:
				$Rock.set_cell(x,y,0)
			
	$Rock.update_bitmask_region(Vector2(0,0),Vector2(map_size.x,map_size.y))

func make_background():
	for x in map_size.x:
		for y in map_size.y:
			if $Rock.get_cell(x,y) == -1:
				$Lava.set_cell(x,y,0)

func make_road_map():
	for x in map_size.x:
		for y in map_size.y:
			var a = noiseImage.get_pixel(x,y).gray()
			if a < road_caps.x and a > road_caps.y:
				$Path.set_cell(x,y,0)
	$Path.update_bitmask_region(Vector2(0,0),Vector2(map_size.x,map_size.y))
