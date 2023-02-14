extends Node2D

export var current_map_size = Vector2(200,200)
export var map_side_size : int = current_map_size.x
export (float,0.0,100.0) var percentage_floors = 54

var neighbor_dir = [Vector2(1,0),Vector2(1,1),Vector2(0,1),
					Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),
					Vector2(1,-1),Vector2(-1,1)]

func _ready():
	randomize()
	make_map()
	
func make_map():
	for x in range (-10, current_map_size.x+10):
		for y in range(-10, current_map_size.y+10):
			$Water.set_cell(x,y,0)
	for x in range (10, current_map_size.x-10):
		for y in range(10, current_map_size.y-20):
			var num = rand_range(0.0,100.0)
			if num < percentage_floors:
				$Water.set_cell(x,y,-1)
				$Land.set_cell(x,y,0)
			else:
				$Land.set_cell(x,y,-1)
				$Water.set_cell(x,y,0)
	$Land.update_bitmask_region(Vector2(0,0),current_map_size)
	#$Water.update_bitmask_region(Vector2(0,0),current_map_size)
	smooth_map()
	smooth_map()
	
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
				$Land.set_cell(x,y,-1)
			elif number_of_neighbor_walls < 4:
				$Land.set_cell(x,y,0)
				$Water.set_cell(x,y,-1)
	
	$Land.update_bitmask_region(Vector2(0,0),current_map_size)
	#$Water.update_bitmask_region(Vector2(0,0),current_map_size)
