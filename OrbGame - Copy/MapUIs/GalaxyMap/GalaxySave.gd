extends Node

const SAVE_FILE = "user://save_file.save"
var game_data = {}

# holding star coordinates for galaxy map
var lastStarClicked
var lastStarClickedName
func setLastStarClicked(starPos,starName):
	lastStarClicked = starPos.x
	lastStarClickedName = starName
	game_data["shipPosition"][0] = starPos
func getLastStarClicked():
	return lastStarClicked
func getLastStarClickedName():
	return lastStarClickedName
	
# holding planet coordinates for galaxy map
var lastPlanetClicked = 0
func setLastPlanetClicked(starPos,planetPos):
	game_data["shipPosition"][7] = planetPos
	lastPlanetClicked = pow(starPos*planetPos,2)*cos(pow(starPos*planetPos,3))
func getLastPlanetClicked():
	return lastPlanetClicked

# getting building data of planet
var building_data = {} # all building data
func set_building_data(data_table):
	building_data[lastPlanetClicked] = data_table
	game_data["buildingData"] = building_data
func get_planet_building_data():
	building_data = game_data["buildingData"]
	if not game_data["buildingData"].has(lastPlanetClicked):
		building_data[lastPlanetClicked] = {}
	return building_data[lastPlanetClicked]


# saving data
func _ready():
	load_data()

func save_data():
	var file = File.new()
	file.open(SAVE_FILE,File.WRITE)
	file.store_var(game_data)
	file.close()

onready var buildingTypes = ConstantsHolder.building_types
onready var shipLocation = ConstantsHolder.ship_locations
func load_data():
	var file = File.new()
	if not file.file_exists(SAVE_FILE) or true:
		randomize()
		game_data = {
			"galaxySeed": randi(),
			"backpackBlood": {"red":0,"blue":0},
			"storedBlood": {"red":0,"blue":0},
			"buildingData": {},
			"storedBuildings":{buildingTypes.WALL:50,buildingTypes.FLOOR:50,buildingTypes.TURRET:50,buildingTypes.CALTROPS:50,buildingTypes.LANDMINE:50,buildingTypes.LASER:50},
			"shipPosition": [Vector2.ZERO,Vector2.ZERO,-2,0,shipLocation.STATION,false,false,0], #galaxy position, system position, ship speed, ship rotation, ship location, is in system, just landed on planet, lastplanet
			"storyProgression": 0 
		}
		save_data()
	file.open(SAVE_FILE,File.READ)
	game_data = file.get_var()
	file.close()

# handling ship position

var rng = RandomNumberGenerator.new()

func set_ship_speed(speed,entering_specific_area = false):
	var ship_position = game_data["shipPosition"][4]
	if game_data["shipPosition"][2] > -2 and speed == -1 or game_data["shipPosition"][2] < 0 and speed == 1 or game_data["shipPosition"][2] == 0 and speed == -2 or game_data["shipPosition"][2] == -2 and speed == 2:
		game_data["shipPosition"][2] = game_data["shipPosition"][2] + speed
	print("NEW SPEED")
	print("planet position" + str(game_data["shipPosition"][1]))
	print("speed = " + str(game_data["shipPosition"][2]))
	print("position = " + str(ConstantsHolder.ship_locations.keys()[game_data["shipPosition"][4]]))
	print("last planet = " + str(lastPlanetClicked))
	print("last star = " + str(lastStarClicked))
	print(GalaxySave.game_data["shipPosition"][5])
	if speed == 1:
		print("increasing speed")
		match ship_position:
			shipLocation.PLANET:
				get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
				game_data["shipPosition"][4] = shipLocation.SYSTEM
				# switch to system, update ship location
			shipLocation.SYSTEM:
				print("in system")
				get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
				# switch to galaxy
			shipLocation.SPACEZOOMED:
				if game_data["shipPosition"][5]: #is in system
					get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
					game_data["shipPosition"][4] = shipLocation.SYSTEM
				else:
					print("not in system")
					get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACE
					# switch to space
			shipLocation.SPACE:
				get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
				# switch to galaxy
	elif speed == -1:
		print("decreasing speed")
		match ship_position:
			shipLocation.GALAXY:
				if entering_specific_area:
					game_data["shipPosition"][4] = shipLocation.SYSTEM
					if game_data["shipPosition"][1] == Vector2.ZERO:
						var values = [-1,1]
						rng.randomize()
						game_data["shipPosition"][1] = Vector2(rng.randf_range(10,200),rng.randf_range(10,200))*Vector2(values[rng.randi()%2],values[rng.randi()%2])
				else:
					get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACE
			shipLocation.SYSTEM:
				if entering_specific_area:
					game_data["shipPosition"][4] = shipLocation.PLANET
					#enter specific planet
				else:
					get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACEZOOMED
			shipLocation.SPACE:
				get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
				game_data["shipPosition"][4] = shipLocation.SPACEZOOMED
			shipLocation.SPACEZOOMED:
				get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
			shipLocation.PLANET:
				GalaxySave.game_data["shipPosition"][6] = false
				get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
			shipLocation.STATION:
				GalaxySave.game_data["shipPosition"][6] = false
				get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
	elif speed == 0:
		match ship_position:
			shipLocation.SPACE:
				get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
			shipLocation.SPACEZOOMED:
				get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
			shipLocation.SYSTEM:
				get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
			shipLocation.PLANET:
				get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")
			shipLocation.STATION:
				get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
	elif speed == -2:
		match ship_position:
			shipLocation.GALAXY:
				game_data["shipPosition"][4] = shipLocation.STATION
				get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
	elif speed == 2:
		match ship_position:
			shipLocation.STATION:
				get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
	print("new position = " + str(ConstantsHolder.ship_locations.keys()[game_data["shipPosition"][4]]))
