extends Node

const SAVE_FILE = "user://save_file.save"
var game_data = {}

# holding star coordinates for galaxy map
var lastStarClicked
var lastStarClickedName
var lastStarType
func setLastStarClicked(starPos,starName,starType):
	lastStarClicked = starPos.x
	lastStarClickedName = starName
	lastStarType = starType
	game_data["shipPosition"][0] = starPos
func getLastStarClicked():
	return lastStarClicked
func getLastStarClickedName():
	return lastStarClickedName
func getLastStarType():
	return lastStarType
	
# holding planet coordinates for galaxy map
var lastPlanetClicked = 0
var lastPlanetType
func setLastPlanetClicked(starPos,planetPos,planetType=null):
	game_data["shipPosition"][7] = planetPos
	lastPlanetClicked = str(pow(starPos*planetPos,2)*cos(pow(starPos*planetPos,3))).hash()
	lastPlanetType = planetType
func getLastPlanetClicked():
	return lastPlanetClicked
func getLastPlanetType():
	return lastPlanetType

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
	# setup player
	PlayerStats.health = game_data["playerHealth"]

func save_data():
	var file = File.new()
	file.open(SAVE_FILE,File.WRITE)
	file.store_var(game_data)
	file.close()

onready var buildingTypes = ConstantsHolder.building_types
onready var shipLocation = ConstantsHolder.ship_locations
func load_data():
	var file = File.new()
	if not file.file_exists(SAVE_FILE):# or true:
		randomize()
		game_data = {
			"galaxySeed": randi(),
			"backpackBlood": {"red":2,"blue":2,"purple":0,"orange":0,"brown":0},
			"storedBlood": {"red":40,"blue":40,"purple":0,"orange":0,"brown":0},
			"buildingData": {},
			"storedBuildings":{buildingTypes.WALL:50,buildingTypes.FLOOR:50,buildingTypes.TURRET:50,buildingTypes.CALTROPS:50,buildingTypes.LANDMINE:50,buildingTypes.LASER:50,buildingTypes.CAPTURER:50},
			"capturedEnemies":[],
			"shipPosition": [Vector2(1800,500),Vector2.ZERO,-2,0,shipLocation.STATION,false,false,0], #galaxy position, system position, ship speed, ship rotation, ship location, is in system, just landed on planet, lastplanet
			"storyProgression": 0,
			"totalKills" : 0,
			"playerHealth" : PlayerStats.health
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
		match ship_position:
			shipLocation.PLANET:
				var _change = get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
				game_data["shipPosition"][4] = shipLocation.SYSTEM
				# switch to system, update ship location
			shipLocation.SYSTEM:
				var _change = get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
				# switch to galaxy
			shipLocation.SPACEZOOMED:
				if game_data["shipPosition"][5]: #is in system
					var _change = get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
					game_data["shipPosition"][4] = shipLocation.SYSTEM
				else:
					var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACE
					# switch to space
			shipLocation.SPACE:
				var _change = get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
				# switch to galaxy
	elif speed == -1:
		match ship_position:
			shipLocation.GALAXY:
				if entering_specific_area:
					game_data["shipPosition"][4] = shipLocation.SYSTEM
					if game_data["shipPosition"][1] == Vector2.ZERO:
						var values = [-1,1]
						rng.randomize()
						game_data["shipPosition"][1] = Vector2(rng.randf_range(10,200),rng.randf_range(10,200))*Vector2(values[rng.randi()%2],values[rng.randi()%2])
				else:
					var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACE
			shipLocation.SYSTEM:
				if entering_specific_area:
					game_data["shipPosition"][4] = shipLocation.PLANET
					#enter specific planet
				else:
					var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
					game_data["shipPosition"][4] = shipLocation.SPACEZOOMED
			shipLocation.SPACE:
				var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
				game_data["shipPosition"][4] = shipLocation.SPACEZOOMED
			shipLocation.SPACEZOOMED:
				var _change = get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
			shipLocation.PLANET:
				GalaxySave.game_data["shipPosition"][6] = false
				var _change = get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
			shipLocation.STATION:
				GalaxySave.game_data["shipPosition"][6] = false
				var _change = get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
	elif speed == 0:
		match ship_position:
			shipLocation.SPACE:
				var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpace.tscn")
			shipLocation.SPACEZOOMED:
				var _change = get_tree().change_scene("res://MapUIs/General/RemoteSpaceZoomed.tscn")
			shipLocation.SYSTEM:
				var _change = get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
			shipLocation.PLANET:
				var _change = get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")
			shipLocation.STATION:
				var _change = get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
	elif speed == -2:
		match ship_position:
			shipLocation.GALAXY:
				game_data["shipPosition"][4] = shipLocation.STATION
				var _change = get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
	elif speed == 2:
		match ship_position:
			shipLocation.STATION:
				var _change = get_tree().change_scene("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
				game_data["shipPosition"][4] = shipLocation.GALAXY
	#print("new position = " + str(ConstantsHolder.ship_locations.keys()[game_data["shipPosition"][4]]))
