extends Node2D

var noise
export var map_side_size = 200
var map_size = Vector2(map_side_size,map_side_size)
var grass_cap = .6
var noiseImage

func _ready():
	$YSort/Player.frozenPlanet = true
	seed(GalaxySave.getLastPlanetClicked())
	make_grass_map()
	make_snow_map()
	make_background()
	get_node("..").ship_position = find_ship_pos()

var lowestA = 1
func make_grass_map():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < lowestA and x > 20 and x < map_side_size-20 and  y > 20 and y < map_side_size-20:
				lowestA = a
				get_node("..").ship_position = Vector2(x*16,y*16)
			if a < grass_cap:
				$Grass.set_cell(x,y,0)
				# set edge corners
				if x <= 20 and y <= 20:
					$Grass.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$Grass.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-20 and y <= 20:
					$Grass.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 20 and y >= map_size.y-20:
					$Grass.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 20:
					$Grass.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-21:
					$Grass.set_cell(x-map_size.x,y,0)
				if y <= 20:
					$Grass.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-21:
					$Grass.set_cell(x,y-map_size.y,0)
			
	$Grass.update_bitmask_region(Vector2(-20,-20),Vector2(map_size.x+20,map_size.y+20))
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < grass_cap:
				var coord = $Grass.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$Grass.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,coord)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$Grass.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,coord)
				elif x >= map_size.x-20 and y <= 20:
					$Grass.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,coord)
				elif x <= 20 and y >= map_size.y-20:
					$Grass.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,coord)

				# set edge sides
				if x <= 20:
					$Grass.set_cell(map_size.x+x,y,0,false,false,false,coord)
				elif x >= map_size.x-21:
					$Grass.set_cell(x-map_size.x,y,0,false,false,false,coord)
				if y <= 20:
					$Grass.set_cell(x,map_size.y+y,0,false,false,false,coord)
				elif y >= map_size.y-21:
					$Grass.set_cell(x,y-map_size.y,0,false,false,false,coord)

func make_snow_map():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if $Grass.get_cell(x,y) != -1 and a < grass_cap:
				$Snow.set_cell(x,y,0)
				# set edge corners
				if x <= 20 and y <= 20:
					$Snow.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$Snow.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-20 and y <= 20:
					$Snow.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 20 and y >= map_size.y-20:
					$Snow.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 20:
					$Snow.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-21:
					$Snow.set_cell(x-map_size.x,y,0)
				if y <= 20:
					$Snow.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-21:
					$Snow.set_cell(x,y-map_size.y,0)
			
	$Snow.update_bitmask_region(Vector2(-20,-20),Vector2(map_size.x+20,map_size.y+20))
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if $Grass.get_cell(x,y) != -1 and a < grass_cap:
				var coord = $Snow.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$Snow.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,coord)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$Snow.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,coord)
				elif x >= map_size.x-20 and y <= 20:
					$Snow.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,coord)
				elif x <= 20 and y >= map_size.y-20:
					$Snow.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,coord)

				# set edge sides
				if x <= 20:
					$Snow.set_cell(map_size.x+x,y,0,false,false,false,coord)
				elif x >= map_size.x-21:
					$Snow.set_cell(x-map_size.x,y,0,false,false,false,coord)
				if y <= 20:
					$Snow.set_cell(x,map_size.y+y,0,false,false,false,coord)
				elif y >= map_size.y-21:
					$Snow.set_cell(x,y-map_size.y,0,false,false,false,coord)
func make_background(): # tiles 6 and 15 are seamless
	var c = [true,false]
	for x in map_size.x+40:
		for y in map_size.y+40:
			$Ice.set_cell(x-20,y-20,6,c[randi() % c.size()],c[randi() % c.size()],c[randi() % c.size()])

func find_ship_pos():
#	print("finding ship pos")
	for x in map_side_size-40:
		for y in map_side_size-40:
			var nearby_ice = false
			for i in range(x+20 - 8, x+20 + 9):
				for v in range(y+20 - 8, y+20 + 9):
					if $Grass.get_cell(i,v) == -1:
#						print("canyons found")
						nearby_ice = true
			if not nearby_ice:
#				print("returning coords" + str(Vector2(x+20,y+20)))
				return Vector2((x+20)*16,(y+20)*16)

func get_spawning_array():
	var tilemap_table = $Ice.get_used_cells()
	return tilemap_table

func _on_Player_teleported(direction):
	var entities = $YSort.get_children()
	entities.erase($YSort/Player)
	direction *= map_side_size
	direction *= 16
	print("teleporting all entities")
	for entity in entities:
		entity.global_position += direction
