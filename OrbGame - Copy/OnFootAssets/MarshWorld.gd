extends Node2D

export var current_map_size = Vector2(200,200)
export var map_side_size : int = current_map_size.x
export (float,0.0,100.0) var percentage_floors = 54

var neighbor_dir = [Vector2(1,0),Vector2(1,1),Vector2(0,1),
					Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),
					Vector2(1,-1),Vector2(-1,1)]

var neighbor_dir_extended = [Vector2(1,0),Vector2(1,1),Vector2(0,1),
					Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),
					Vector2(1,-1),Vector2(-1,1),Vector2(2,0),Vector2(2,2),Vector2(0,2),
					Vector2(-2,0),Vector2(-2,-2),Vector2(0,-2),
					Vector2(2,-2),Vector2(-2,2),Vector2(1,2),Vector2(2,1),Vector2(2,-1),
					Vector2(1,-2),Vector2(-1,-2),Vector2(-2,-1),
					Vector2(-2,1),Vector2(-1,2),
					Vector2(-3,0),Vector2(3,0),Vector2(0,3),Vector2(0,-3)]

var ship_dir = [Vector2(2,0),Vector2(2,1),Vector2(2,-1),Vector2(2,-2),Vector2(2,-3),Vector2(2,-4),
				Vector2(3,0),Vector2(3,1),Vector2(3,-1),Vector2(3,-2),Vector2(3,-3),Vector2(3,-4),
				Vector2(4,0),Vector2(4,1),Vector2(4,-1),Vector2(4,-2),Vector2(4,-3),Vector2(4,-4),
				Vector2(5,0),Vector2(5,1),Vector2(5,-1),Vector2(5,-2),Vector2(5,-3),Vector2(5,-4),
				Vector2(6,0),Vector2(6,1),Vector2(6,-1),Vector2(6,-2),Vector2(6,-3),Vector2(6,-4)]

func _ready():
	seed(GalaxySave.getLastPlanetClicked())
	make_map()
	
func make_map():
	for x in range (-10, current_map_size.x+10):
		for y in range(-10, current_map_size.y+10):
			$Water.set_cell(x,y,0)
	for x in range (10, current_map_size.x-10):
		for y in range(10, current_map_size.y-20):
			var num = rand_range(0.0,100.0)
			if num < percentage_floors:
				$Sand.set_cell(x,y,0)
				$Water.set_cell(x,y,-1)
			else:
				$Water.set_cell(x,y,0)
				$Sand.set_cell(x,y,-1)
	$Sand.update_bitmask_region(Vector2(0,0),current_map_size)
	#$Water.update_bitmask_region(Vector2(0,0),current_map_size)
	smooth_map()
	smooth_map()
	smooth_map()
	add_land_layer()
	
func smooth_map():
	for x in range(10,current_map_size.x -10):
		for y in range(10,current_map_size.y-10):
			var number_of_neighbor_walls = 0
			for direction in neighbor_dir:
				var current_tile = Vector2(x,y) + direction
				if $Water.get_cell(current_tile.x,current_tile.y) == 0:
					number_of_neighbor_walls += 1
			if number_of_neighbor_walls > 4:
				$Water.set_cell(x,y,0)
				$Sand.set_cell(x,y,-1)
				$YSort/Objects.set_cell(x,y,-1)
				var chance = randi()%100
				if chance < 2:
					$LilyPads.set_cell(x,y,randi()%8)
			elif number_of_neighbor_walls < 4:
				$Sand.set_cell(x,y,0)
				$Water.set_cell(x,y,-1)
				$LilyPads.set_cell(x,y,-1)
				var chance = randi()%200
				if chance < 2 and number_of_neighbor_walls == 0:
					$YSort/Objects.set_cell(x,y,randi()%19)
	
	$Sand.update_bitmask_region(Vector2(0,0),current_map_size)
	#$Water.update_bitmask_region(Vector2(0,0),current_map_size)

func add_land_layer():
	var replace_tiles = []
	var ship_location_found = false
	for x in range(10,current_map_size.x -10):
		for y in range(10,current_map_size.y-10):
			
			var number_of_neighbor_sand = 0
			for direction in neighbor_dir_extended:
				var current_tile = Vector2(x,y) + direction
				if $Sand.get_cell(current_tile.x,current_tile.y) == 0:
					number_of_neighbor_sand += 1
			if number_of_neighbor_sand > 24:
				if $Water.get_cell(x,y) == -1:
					replace_tiles.append(Vector2(x,y))
			if not ship_location_found:
				var ship_check = true
				for direction in ship_dir:
					var current_tile = Vector2(x,y) + direction
					if $Water.get_cell(current_tile.x,current_tile.y) == 0:
						ship_check = false
				if number_of_neighbor_sand > 24 and x > 30 and y > 30 and x < current_map_size.x - 30 and y < current_map_size.y - 30 and ship_check:
					get_node("..").ship_position = Vector2(x*16,y*16)
					ship_location_found = true
	for i in replace_tiles:
		$Land.set_cell(i.x,i.y,0)
		var chance = randi()%200
		var flip = [true,false]
		var trees = [0,1,4,6,7]
		if chance < 2:
			$YSort/Trees.set_cell(i.x,i.y,trees[randi() % trees.size()],flip[randi() % flip.size()])
	
	$Land.update_bitmask_region(Vector2(0,0),current_map_size)
	$Sand.update_bitmask_region(Vector2(0,0),current_map_size)
	$YSort/Player.global_position = Vector2(500,560)

func get_spawning_array():
	var tilemap_table = $Sand.get_used_cells()
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
