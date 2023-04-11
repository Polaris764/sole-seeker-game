extends Container

onready var planet = preload("res://MapUIs/InsideSystem/PlanetHolder.tscn")
var planetAmountOptions = [0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,10,11,12,13,14]
var starAmountOptions = [1]
func generatePlanetarySystem(seedUsed):
	var keyedSeed = pow(seedUsed,2)*cos(pow(seedUsed,3))
	seed(keyedSeed)
	var planetAmount = planetAmountOptions[randi() % planetAmountOptions.size()]
	var starAmount = 1 #starAmountOptions[randi() % starAmountOptions.size()]
	if starAmount == 1: # generate single star system
		for i in range(planetAmount):
			var radius = (i+1) * rand_range (235,270)
			var new_planet = planet.instance()
			add_child(new_planet)
			new_planet.position = $Star.global_position
			new_planet.get_node("Planet").margin_right = new_planet.get_node("Planet").margin_right + radius
			new_planet.get_node("Planet").margin_left = radius
			#warning-ignore:integer_division
			new_planet.set_rotation(deg2rad(rand_range(0,360)+Time.get_ticks_msec()/100))
			new_planet.get_node("Planet/PlanetImage").set_rotation(rand_range(0,360))
			new_planet.get_node("Planet/PlanetImage").modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1)
			new_planet.planetPlace = i+1

onready var player = get_node("../Player")
func _ready():
	var posSeed = GalaxySave.getLastStarClicked()
	generatePlanetarySystem(posSeed)
	player.global_position = GalaxySave.game_data["shipPosition"][1]
	GalaxySave.game_data["shipPosition"][5] = true
	var planet_position = GalaxySave.game_data["shipPosition"][7]
	if planet_position > 0:
		player.global_position = get_children()[planet_position].get_node("Planet/PlanetImage").global_position
		planet_position = 0
		#print("setting at planet location. Player position = " + str(player.global_position) + ". Target planet = " + str(get_children()[planet_position]))
	GalaxySave.save_data()
