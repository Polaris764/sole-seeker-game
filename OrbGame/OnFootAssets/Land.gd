extends TileMap
#
#enum TILES {Land,Water}
#
#export var current_map_size = Vector2(200,200)
#export (float,0.0,100.0) var percentage_floors = 50
#
#var neighbor_dir = [Vector2(1,0),Vector2(1,1),Vector2(0,1),
#					Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),
#					Vector2(1,-1),Vector2(-1,1)]
#
#func _ready():
#	randomize()
#	make_map()
#
#func make_map():
#	for x in range (1, current_map_size.x-1):
#		for y in range(1, current_map_size.y-1):
#			var num = rand_range(0.0,100.0)
#			if num < percentage_floors:
#				set_cell(x,y,0)
#			else:
#				set_cell(x,y,-1)
#	yield(get_tree().create_timer(3), "timeout")
#	smooth_map()
#	yield(get_tree().create_timer(3), "timeout")
#	smooth_map()
#func smooth_map():
#	for x in range(1,current_map_size.x -1):
#		for y in range(1,current_map_size.y-1):
#			var number_of_neighbor_walls = 0
#			for direction in neighbor_dir:
#				var current_tile = Vector2(x,y) + direction
#				if get_cell(current_tile.x,current_tile.y) == -1:
#					number_of_neighbor_walls += 1
#			if number_of_neighbor_walls > 4:
#				set_cell(x,y,-1)
#			elif number_of_neighbor_walls < 4:
#				set_cell(x,y,0)
