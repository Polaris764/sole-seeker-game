extends Node2D

var current_map_size = Vector2(200,200)
export var map_side_size : int = current_map_size.x
var starting_point_count = 2
var astar_map
onready var rng = RandomNumberGenerator.new()

func _ready():
	AudioManager.play_song([AudioManager.songs.will,AudioManager.songs.dry],"desert")
	rng.seed = (GalaxySave.getLastPlanetClicked())
	make_map()

func _exit_tree():
	AudioManager.stop_song("desert")

func make_map():
	
	# forming background
	for x in current_map_size.x+40:
		for y in current_map_size.y+40:
			$Sand.set_cell(x-20,y-20,0)
	
	# creating impact points
	var number_of_impact_points = (rng.randi()%2+2)
	var impact_locations = []
	for _i in range(number_of_impact_points):
		impact_locations.append(Vector2(rng.randi_range(0,current_map_size.x),rng.randi_range(0,current_map_size.y)))

	# creating point tendrils
	for point in impact_locations:
		#print("making impact location at " + str(point))
		var tendril_amount = rng.randi()%3 + 4
		var possible_tendril_directions2 = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]
		$Sand.set_cell(point.x,point.y,-1)
		for neighbor_cell in possible_tendril_directions2:
			$Sand.set_cell(point.x+neighbor_cell.x,point.y+neighbor_cell.y,-1)
		for tendril in tendril_amount:
			var possible_tendril_directions = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]
			var length = rng.randi() % int(current_map_size.x) + 5
			#print("making tendril with length of " + str(length))
			var _tendril_points = []
			var primaryPos = rng.randi() % possible_tendril_directions.size()
			var primary_tendril_direction = possible_tendril_directions[primaryPos]
			possible_tendril_directions.remove(primaryPos)
			if primary_tendril_direction == Vector2(-1,0):
				possible_tendril_directions.erase(Vector2(1,0))
			elif primary_tendril_direction == Vector2(1,0):
				possible_tendril_directions.erase(Vector2(-1,0))
			elif primary_tendril_direction == Vector2(0,1):
				possible_tendril_directions.erase(Vector2(0,-1))
			elif primary_tendril_direction == Vector2(0,-1):
				possible_tendril_directions.erase(Vector2(0,1))
			var secondary_tendril_direction = possible_tendril_directions[rng.randi() % possible_tendril_directions.size()]
			var current_tendril_position : Vector2 = point
			var tendril_curve_factor = randi()%4 + 1
			#print("curve factor: " + str(tendril_curve_factor))
			#print("primary pos: " + str(primary_tendril_direction) + "secondary pos: " + str(secondary_tendril_direction))
			var consecutive_secondaries : int = 0
			var consecutive_primaries : int = 0
			for tile in length:
				if randi() % tendril_curve_factor > 0 and consecutive_primaries < randi()%5:
					consecutive_primaries += 1
					consecutive_secondaries = 0
					current_tendril_position = current_tendril_position + primary_tendril_direction
					#print("going primary")
				elif consecutive_secondaries < randi()%5:
					consecutive_primaries = 0
					consecutive_secondaries += 1
					#print(randi() % tendril_curve_factor)
					#print("going secondary")
					current_tendril_position = current_tendril_position + secondary_tendril_direction
				else:
					consecutive_primaries += 1
					consecutive_secondaries = 0
					current_tendril_position = current_tendril_position + primary_tendril_direction
					#print("going primary")
				$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y,0)
				$Canyon.set_cell(current_tendril_position.x-1,current_tendril_position.y,0)
				$Canyon.set_cell(current_tendril_position.x+1,current_tendril_position.y,0)
				$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y-1,0)
				$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y+1,0)
				# mirroring points
				if current_tendril_position.x < 20 and current_tendril_position.y < 20:
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x-1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x+1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y+current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y+current_map_size.y+1,0)
				elif current_tendril_position.x > current_map_size.x-20 and current_tendril_position.y > current_map_size.y-20:
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x-1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x+1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y-current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y-current_map_size.y+1,0)
				if current_tendril_position.x < 20 and current_tendril_position.y > current_map_size.y-20:
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x-1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x+1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y-current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y-current_map_size.y+1,0)
				elif current_tendril_position.x > current_map_size.x - 20 and current_tendril_position.y < 20:
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x-1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x+1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y+current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y+current_map_size.y+1,0)
				if current_tendril_position.x < 20:
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x-1,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x+1,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y-1,0)
					$Canyon.set_cell(current_tendril_position.x+current_map_size.x,current_tendril_position.y+1,0)
				if current_tendril_position.x > current_map_size.x-20:
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x-1,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x+1,current_tendril_position.y,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y-1,0)
					$Canyon.set_cell(current_tendril_position.x-current_map_size.x,current_tendril_position.y+1,0)
				if current_tendril_position.y < 20:
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+1,current_tendril_position.y+current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y+current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y+current_map_size.y+1,0)
				if current_tendril_position.y > current_map_size.y-20:
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x-1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x+1,current_tendril_position.y-current_map_size.y,0)
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y-current_map_size.y-1,0)
					$Canyon.set_cell(current_tendril_position.x,current_tendril_position.y-current_map_size.y+1,0)
#				yield(get_tree(),"idle_frame")
#				yield(get_tree(),"idle_frame")
#				yield(get_tree(),"idle_frame")
	$Canyon.update_bitmask_region(Vector2(-20,-20),Vector2(current_map_size.x+20,current_map_size.y+20))
	get_node("..").ship_position = find_ship_pos()
	
#finding ship position
func find_ship_pos():
#	print("finding ship pos")
	for x in current_map_size.x-40:
		for y in current_map_size.y-40:
			var nearby_canyons = false
			for i in range(x+20 - 8, x+20 + 9):
				for v in range(y+20 - 8, y+20 + 9):
					if $Canyon.get_cell(i,v) != -1:
#						print("canyons found")
						nearby_canyons = true
			if not nearby_canyons:
#				print("returning coords" + str(Vector2(x+20,y+20)))
				return Vector2((x+20)*16,(y+20)*16)

func get_spawning_array():
	var tilemap_table = $Sand.get_used_cells()
	return tilemap_table

func _on_Player_teleported(direction):
	var entities = $YSort.get_children()
	entities.erase($YSort/Player)
	direction *= map_side_size
	direction *= 16
	print("teleporting all entities")
	for entity in entities:
		entity.global_position += direction
