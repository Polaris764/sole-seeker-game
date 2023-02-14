extends Node

const SAVE_FILE = "user://save_file.save"
var game_data = {}

# holding star coordinates for galaxy map
var lastStarClicked
var lastStarClickedName
func setLastStarClicked(starPos,starName):
	lastStarClicked = starPos
	lastStarClickedName = starName
func getLastStarClicked():
	return lastStarClicked
func getLastStarClickedName():
	return lastStarClickedName
	
# holding planet coordinates for galaxy map
var lastPlanetClicked = 1
func setLastPlanetClicked(starPos,planetPos):
	lastPlanetClicked = pow(starPos*planetPos,2)*cos(pow(starPos*planetPos,3))
func getLastPlanetClicked():
	return lastPlanetClicked

# getting building data of planet
var building_data = {} # all building data
func set_building_data(data_table):
	building_data[lastPlanetClicked] = data_table
	game_data["buildingData"] = building_data
	print(building_data[lastPlanetClicked].size())
func get_planet_building_data():
	building_data = game_data["buildingData"]
	if not game_data["buildingData"].has(lastPlanetClicked):
		building_data[lastPlanetClicked] = {}
	print(building_data)
	return building_data[lastPlanetClicked]

# saving data
func _ready():
	load_data()

func save_data():
	var file = File.new()
	file.open(SAVE_FILE,File.WRITE)
	file.store_var(game_data)
	file.close()
	
func load_data():
	var file = File.new()
	if not file.file_exists(SAVE_FILE):
		randomize()
		game_data = {
			"galaxySeed": randi(),
			"backpackBlood": {"red":0,"blue":0},
			"storedBlood": {"red":0,"blue":0},
			"buildingData": {},
			"storedBuildings":{"Wall":0,"Floor":0,"Turret":0,"Caltrops":0,"Landmine":0,"Laser":0}
		}
		save_data()
	file.open(SAVE_FILE,File.READ)
	game_data = file.get_var()
	file.close()
