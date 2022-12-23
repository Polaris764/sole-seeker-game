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
var lastPlanetClicked
func setLastPlanetClicked(starPos,planetPos):
	lastPlanetClicked = pow(starPos*planetPos,2)*cos(pow(starPos*planetPos,3))
func getLastPlanetClicked():
	return lastPlanetClicked

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
			"playerLevel": 1
		}
		save_data()
	file.open(SAVE_FILE,File.READ)
	game_data = file.get_var()
	file.close()
