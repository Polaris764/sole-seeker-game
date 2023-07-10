extends Node2D

var noise
export var map_side_size = 200
var map_size = Vector2(map_side_size,map_side_size)
var third_layer_cap = .45
var noiseImage

func _ready():
	seed(GalaxySave.getLastPlanetClicked())
	make_lowest_rust()
	make_second_layer()
	make_third_layer()
	make_background()

func make_lowest_rust():
	var crater_radii = [2,3,4,5,6,7,8]
	var circle_cells = [
	[Vector2(0,0)],
	[Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0),Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)],
	[Vector2(-1,2),Vector2(0,2),Vector2(1,2),Vector2(2,1),Vector2(2,0),Vector2(2,-1),Vector2(-1,-2),Vector2(0,-2),Vector2(1,-2),Vector2(-2,-1),Vector2(-2,0),Vector2(-2,1)],
	[Vector2(-1,3),Vector2(0,3),Vector2(1,3),Vector2(3,1),Vector2(3,0),Vector2(3,-1),Vector2(-1,-3),Vector2(0,-3),Vector2(1,-3),Vector2(-3,-1),Vector2(-3,0),Vector2(-3,1),Vector2(2,2),Vector2(2,-2),Vector2(-2,2),Vector2(-2,-2)],
	[Vector2(-1,4),Vector2(0,4),Vector2(1,4),Vector2(4,1),Vector2(4,0),Vector2(4,-1),Vector2(-1,-4),Vector2(0,-4),Vector2(1,-4),Vector2(-4,-1),Vector2(-4,0),Vector2(-4,1),Vector2(2,4),Vector2(2,-4),Vector2(-2,4),Vector2(-2,-4),Vector2(4,2),Vector2(4,-2),Vector2(-4,2),Vector2(-4,-2),Vector2(3,3),Vector2(3,-3),Vector2(-3,-3),Vector2(-3,3),Vector2(2,3),Vector2(2,-3),Vector2(-2,3),Vector2(-2,-3),Vector2(3,2),Vector2(3,-2),Vector2(-3,2),Vector2(-3,-2)],
	[Vector2(-1,5),Vector2(0,5),Vector2(1,5),Vector2(5,1),Vector2(5,0),Vector2(5,-1),Vector2(-1,-5),Vector2(0,-5),Vector2(1,-5),Vector2(-5,-1),Vector2(-5,0),Vector2(-5,1),Vector2(2,5),Vector2(2,-5),Vector2(-2,5),Vector2(-2,-5),Vector2(5,2),Vector2(5,-2),Vector2(-5,2),Vector2(-5,-2),Vector2(4,3),Vector2(4,-3),Vector2(-4,3),Vector2(-4,-3),Vector2(3,4),Vector2(3,-4),Vector2(-3,4),Vector2(-3,-4)],
	[Vector2(-2,6),Vector2(-1,6),Vector2(0,6),Vector2(1,6),Vector2(2,6),Vector2(-2,-6),Vector2(-1,-6),Vector2(0,-6),Vector2(1,-6),Vector2(2,-6),Vector2(6,2),Vector2(6,1),Vector2(6,0),Vector2(6,-1),Vector2(6,-2),Vector2(-6,-2),Vector2(-6,-1),Vector2(-6,0),Vector2(-6,1),Vector2(-6,2),Vector2(-3,5),Vector2(3,5),Vector2(-3,-5),Vector2(3,-5),Vector2(-5,3),Vector2(-5,-3),Vector2(5,3),Vector2(5,-3),Vector2(4,4),Vector2(4,-4),Vector2(-4,4),Vector2(-4,-4),Vector2(-5,-4),Vector2(-5,4),Vector2(5,-4),Vector2(5,4),Vector2(4,-5),Vector2(4,5),Vector2(-4,-5),Vector2(-4,5)],
	[Vector2(-2,7),Vector2(-1,7),Vector2(0,7),Vector2(1,7),Vector2(2,7),Vector2(-2,-7),Vector2(-1,-7),Vector2(0,-7),Vector2(1,-7),Vector2(2,-7),Vector2(7,2),Vector2(7,1),Vector2(7,0),Vector2(7,-1),Vector2(7,-2),Vector2(-7,2),Vector2(-7,1),Vector2(-7,0),Vector2(-7,-1),Vector2(-7,-2),Vector2(5,5),Vector2(5,-5),Vector2(-5,5),Vector2(-5,-5),Vector2(-6,3),Vector2(-6,-3),Vector2(6,3),Vector2(6,-3),Vector2(-6,4),Vector2(-6,-4),Vector2(6,4),Vector2(6,-4),Vector2(-3,6),Vector2(-3,-6),Vector2(3,6),Vector2(3,-6),Vector2(-4,6),Vector2(-4,-6),Vector2(4,6),Vector2(4,-6)]
	]
	var amount_of_craters = randi()%20+30
	var largest_crater = 0
	var center_of_largest = Vector2(100,100)
	for _i in range(amount_of_craters):
		var location = Vector2(map_side_size-((randi()%map_side_size)+1),map_side_size-((randi()%map_side_size)+1))
		var radius = crater_radii[randi() % crater_radii.size()]
		var _circle_tiles = []
		#finding ship pos
		if radius > largest_crater and location.x > 20 and location.y > 20 and location.x < map_side_size-20 and location.y < map_side_size-20:
			largest_crater = radius
			center_of_largest = location
		for unit in range(radius):
			var additional_cells = circle_cells[unit]
			for additional_cell in additional_cells:
				var cell_decal = randi()%48
				var x = location.x+additional_cell.x
				var y = location.y+additional_cell.y
				$LowerRust.set_cell(x,y,cell_decal)
				if x <= 20 and y <= 20:
					$LowerRust.set_cell(map_size.x+x,map_size.y+y,cell_decal)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$LowerRust.set_cell(x-map_size.x,y-map_size.y,cell_decal)
				elif x >= map_size.x-20 and y <= 20:
					$LowerRust.set_cell(x-map_size.x,map_size.y+y,cell_decal)
				elif x <= 20 and y >= map_size.y-20:
					$LowerRust.set_cell(map_size.x+x,y-map_size.y,cell_decal)

				# set edge sides
				if x <= 20:
					$LowerRust.set_cell(map_size.x+x,y,cell_decal)
				elif x >= map_size.x-21:
					$LowerRust.set_cell(x-map_size.x,y,cell_decal)
				if y <= 20:
					$LowerRust.set_cell(x,map_size.y+y,cell_decal)
				elif y >= map_size.y-21:
					$LowerRust.set_cell(x,y-map_size.y,cell_decal)
	get_node("..").ship_position = center_of_largest*Vector2(16,16)

func make_second_layer():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var _a = noiseImage.get_pixel(x,y).gray()
			if $LowerRust.get_cell(x,y) == -1:
				$UpperRust.set_cell(x,y,0)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperRust.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperRust.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-20 and y <= 20:
					$UpperRust.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 20 and y >= map_size.y-20:
					$UpperRust.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 20:
					$UpperRust.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-21:
					$UpperRust.set_cell(x-map_size.x,y,0)
				if y <= 20:
					$UpperRust.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-21:
					$UpperRust.set_cell(x,y-map_size.y,0)
			
	$UpperRust.update_bitmask_region(Vector2(-20,-20),Vector2(map_size.x+20,map_size.y+20))
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			if $LowerRust.get_cell(x,y) == -1:
				var tile_used = $UpperRust.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperRust.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,tile_used)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperRust.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,tile_used)
				elif x >= map_size.x-20 and y <= 20:
					$UpperRust.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,tile_used)
				elif x <= 20 and y >= map_size.y-20:
					$UpperRust.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,tile_used)

				# set edge sides
				if x <= 20:
					$UpperRust.set_cell(map_size.x+x,y,0,false,false,false,tile_used)
				elif x >= map_size.x-21:
					$UpperRust.set_cell(x-map_size.x,y,0,false,false,false,tile_used)
				if y <= 20:
					$UpperRust.set_cell(x,map_size.y+y,0,false,false,false,tile_used)
				elif y >= map_size.y-21:
					$UpperRust.set_cell(x,y-map_size.y,0,false,false,false,tile_used)

func make_third_layer():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 12

	noiseImage = noise.get_seamless_image(map_size.x)
	noiseImage.lock()
	for x in range(map_size.x):
		for y in range(map_size.y):
			var a = noiseImage.get_pixel(x,y).gray()
			if a < third_layer_cap and $UpperRust.get_cell(x,y) != -1:
				$UpperRust2.set_cell(x,y,0)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperRust2.set_cell(map_size.x+x,map_size.y+y,0)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperRust2.set_cell(x-map_size.x,y-map_size.y,0)
				elif x >= map_size.x-20 and y <= 20:
					$UpperRust2.set_cell(x-map_size.x,map_size.y+y,0)
				elif x <= 20 and y >= map_size.y-20:
					$UpperRust2.set_cell(map_size.x+x,y-map_size.y,0)

				# set edge sides
				if x <= 20:
					$UpperRust2.set_cell(map_size.x+x,y,0)
				elif x >= map_size.x-21:
					$UpperRust2.set_cell(x-map_size.x,y,0)
				if y <= 20:
					$UpperRust2.set_cell(x,map_size.y+y,0)
				elif y >= map_size.y-21:
					$UpperRust2.set_cell(x,y-map_size.y,0)
			
	$UpperRust2.update_bitmask_region(Vector2(-20,-20),Vector2(map_size.x+20,map_size.y+20))
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			if $UpperRust2.get_cell(x,y) != -1:
				var tile_used = $UpperRust2.get_cell_autotile_coord(x,y)
				# set edge corners
				if x <= 20 and y <= 20:
					$UpperRust2.set_cell(map_size.x+x,map_size.y+y,0,false,false,false,tile_used)
				elif x >= map_size.x-20 and y >= map_size.y-20:
					$UpperRust2.set_cell(x-map_size.x,y-map_size.y,0,false,false,false,tile_used)
				elif x >= map_size.x-20 and y <= 20:
					$UpperRust2.set_cell(x-map_size.x,map_size.y+y,0,false,false,false,tile_used)
				elif x <= 20 and y >= map_size.y-20:
					$UpperRust2.set_cell(map_size.x+x,y-map_size.y,0,false,false,false,tile_used)

				# set edge sides
				if x <= 20:
					$UpperRust2.set_cell(map_size.x+x,y,0,false,false,false,tile_used)
				elif x >= map_size.x-21:
					$UpperRust2.set_cell(x-map_size.x,y,0,false,false,false,tile_used)
				if y <= 20:
					$UpperRust2.set_cell(x,map_size.y+y,0,false,false,false,tile_used)
				elif y >= map_size.y-21:
					$UpperRust2.set_cell(x,y-map_size.y,0,false,false,false,tile_used)

func make_background():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell_decal = randi()%48
			$LowerRust.set_cell(x,y,cell_decal)
			# set edge corners
			if x <= 20 and y <= 20:
				$LowerRust.set_cell(map_size.x+x,map_size.y+y,cell_decal)
			elif x >= map_size.x-20 and y >= map_size.y-20:
				$LowerRust.set_cell(x-map_size.x,y-map_size.y,cell_decal)
			elif x >= map_size.x-20 and y <= 20:
				$LowerRust.set_cell(x-map_size.x,map_size.y+y,cell_decal)
			elif x <= 20 and y >= map_size.y-20:
				$LowerRust.set_cell(map_size.x+x,y-map_size.y,cell_decal)

			# set edge sides
			if x <= 20:
				$LowerRust.set_cell(map_size.x+x,y,cell_decal)
			elif x >= map_size.x-21:
				$LowerRust.set_cell(x-map_size.x,y,cell_decal)
			if y <= 20:
				$LowerRust.set_cell(x,map_size.y+y,cell_decal)
			elif y >= map_size.y-21:
				$LowerRust.set_cell(x,y-map_size.y,cell_decal)

func get_spawning_array():
	var tilemap_table = $UpperRust.get_used_cells()
	tilemap_table.append_array($UpperRust2.get_used_cells())
	return tilemap_table

func _on_Player_teleported(direction):
	var entities = $YSort.get_children()
	entities.erase($YSort/Player)
	var entities_edited = []
	for item in entities:
		if item is KinematicBody2D:
			entities_edited.append(item)
	direction *= map_side_size
	direction *= 16
	print("teleporting all entities")
	for entity in entities_edited:
		entity.global_position += direction
