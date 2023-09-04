extends Node

var SAVE_FILE_PATH = "user://saves/"
var SAVE_FILE = "save_file.save"
var game_data = {}

# holding star coordinates for galaxy map
func setLastStarClicked(starPos,starName,starType):
	game_data["starInfo"]["lastStar"] = starPos.x
	game_data["starInfo"]["lastStarName"] = starName
	game_data["starInfo"]["lastStarType"] = starType
	game_data["shipPosition"][0] = starPos
func getLastStarClicked():
	return game_data["starInfo"]["lastStar"]
func getLastStarClickedName():
	return game_data["starInfo"]["lastStarName"]
func getLastStarType():
	return game_data["starInfo"]["lastStarType"]
	
# holding planet coordinates for galaxy map
func setLastPlanetClicked(starPos,planetPos,planetType=null):
	game_data["shipPosition"][7] = planetPos
	game_data["planetInfo"]["lastPlanet"] = str(pow(starPos*planetPos,2)*cos(pow(starPos*planetPos,3))).hash()
	game_data["planetInfo"]["lastPlanetType"] = planetType
func getLastPlanetClicked():
	return game_data["planetInfo"]["lastPlanet"]
func getLastPlanetType():
	return game_data["planetInfo"]["lastPlanetType"]

# getting building data of planet
var building_data = {} # all building data
func set_building_data(data_table):
	building_data[game_data["planetInfo"]["lastPlanet"]] = data_table
	game_data["buildingData"] = building_data
func get_planet_building_data():
	building_data = game_data["buildingData"]
	if not game_data["buildingData"].has(game_data["planetInfo"]["lastPlanet"]):
		building_data[game_data["planetInfo"]["lastPlanet"]] = {}
	return building_data[game_data["planetInfo"]["lastPlanet"]]

# saving data
var save_notif = preload("res://UIResources/SaveNotification.tscn")
func save_data():
	get_tree().root.add_child(save_notif.instance())
	if get_tree().current_scene.filename != "res://MainMenu/UIHolder.tscn":
		game_data["playerLocation"]["scene"] = get_tree().current_scene.filename
	var playerInstance = get_tree().get_nodes_in_group("Player")
	if playerInstance.size() > 0 and playerInstance[0].global_position:
		game_data["playerLocation"]["position"] = playerInstance[0].global_position
	var file = File.new()
	file.open(SAVE_FILE_PATH + SAVE_FILE,File.WRITE)
	file.store_var(game_data)
	file.close()

onready var buildingTypes = ConstantsHolder.building_types
onready var shipLocation = ConstantsHolder.ship_locations
func load_data():
	ConstantsHolder.reset_variables()
	var directory = Directory.new()
	if not directory.dir_exists(SAVE_FILE_PATH):
		directory.make_dir(SAVE_FILE_PATH)
	var file = File.new()
	if not file.file_exists(SAVE_FILE_PATH + SAVE_FILE):
		randomize()
		game_data = {
			"galaxySeed": randi(),
			"gameModifications": {"megasystems":false,"glassCannon":false,"speedDemon":false,"populationBoom":false,"agingGalaxy":false,"fuelEfficient":false},
			"playerLocation": {"scene":"res://OnFootAssets/Village/Village.tscn","position":null},
			"backpackBlood": {"red":0,"blue":0,"purple":0,"orange":0,"brown":0,"green":0},
			"storedBlood": {"red":0,"blue":0,"purple":0,"orange":0,"brown":0,"green":0},
			"buildingData": {},
			"storedBuildings": {buildingTypes.WALL:0,buildingTypes.FLOOR:0,buildingTypes.TURRET:0,buildingTypes.CALTROPS:0,buildingTypes.LANDMINE:0,buildingTypes.LASER:0,buildingTypes.CAPTURER:0,buildingTypes.CANNON_BASE:0,buildingTypes.CANNON_TURRET:0,buildingTypes.CANNON_POWER:0},
			"capturedEnemies": [],#["BlueOrb","BrownEnemy","Round"],
			"shipPosition": [Vector2.ZERO,Vector2.ZERO,0,0,shipLocation.STATION,false,false,0], #galaxy position, system position, ship speed, ship rotation, ship location, is in system, just landed on planet, lastplanet
			"storyProgression": 0,
			"totalKills" : 0,
			"individualKills" : {"black":0,"blue":0,"brown":0,"orange":0,"green":0,"red":0,"purple":0},
			"playerHealth" : PlayerStats.max_health,
			"enemiesContacted": [],
			"cannonPartsBought":{buildingTypes.CANNON_BASE:false,buildingTypes.CANNON_TURRET:false,buildingTypes.CANNON_POWER:false},
			"cannonLocation": null,
			"starsVisitedArray": [],
			"starsVisitedDictionary": {},
			"bookmarkedStars": {},
			"starInfo": {"lastStar":null,"lastStarName":null,"lastStarType":null},
			"planetInfo": {"lastPlanet":0,"lastPlanetType":null}
		}
		save_data()
	file.open(SAVE_FILE_PATH + SAVE_FILE,File.READ)
	game_data = file.get_var()
	file.close()

func start_game():
	# set up player
	if GalaxySave.game_data["gameModifications"]["glassCannon"]:
		PlayerStats.max_health = PlayerStats.max_health_glass
	PlayerStats.health = game_data["playerHealth"]
	var scene_tree = get_tree() 
	var new_scene = scene_tree.change_scene(game_data["playerLocation"]["scene"])
	if new_scene != OK:
		print(new_scene)
	yield(scene_tree,"node_added")
	yield(scene_tree.current_scene,"ready")
	var playerNode = scene_tree.get_nodes_in_group("Player")[0]
	if game_data["playerLocation"]["position"]:
		playerNode.global_position = game_data["playerLocation"]["position"]

# handling ship position

var rng = RandomNumberGenerator.new()

func set_ship_speed(speed,entering_specific_area = false):
	var ship_position = game_data["shipPosition"][4]
	if game_data["shipPosition"][2] > -2 and speed == -1 or game_data["shipPosition"][2] < 0 and speed == 1 or game_data["shipPosition"][2] == 0 and speed == -2 or game_data["shipPosition"][2] == -2 and speed == 2:
		game_data["shipPosition"][2] = game_data["shipPosition"][2] + speed
#	print("NEW SPEED")
#	print("planet position" + str(game_data["shipPosition"][1]))
#	print("speed = " + str(game_data["shipPosition"][2]))
#	print("position = " + str(ConstantsHolder.ship_locations.keys()[game_data["shipPosition"][4]]))
#	print("last planet = " + str(lastPlanetClicked))
#	print("last star = " + str(lastStarClicked))
#	print(GalaxySave.game_data["shipPosition"][5])
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
				print("inside ship")
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
