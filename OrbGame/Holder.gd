extends Container

onready var planet = preload("res://MapUIs/InsideSystem/PlanetHolder.tscn")
var planetAmountOptions = [0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,10,11,12,13,14]
var starAmountOptions = [1]
func generatePlanetarySystem(seedUsed):
	var keyedSeed = pow(seedUsed,2)*cos(pow(seedUsed,3))
	seed(keyedSeed)
	var starAmount = starAmountOptions[randi() % starAmountOptions.size()]
	if starAmount == 1: # generate single star system
		var planetAmount = planetAmountOptions[randi() % planetAmountOptions.size()]
		for i in range(planetAmount):
			var radius = (i+1) * rand_range (235,270)
			var new_planet = planet.instance()
			add_child(new_planet)
			new_planet.position = $Star.global_position
			new_planet.get_node("Planet").margin_right = new_planet.get_node("Planet").margin_right + radius
			new_planet.get_node("Planet").margin_left = radius
			new_planet.set_rotation(rand_range(0,360))
			new_planet.get_node("Planet/PlanetImage").set_rotation(rand_range(0,360))
			new_planet.get_node("Planet/PlanetImage").modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1)
			new_planet.planetPlace = i+1

func _ready():
	var posSeed = GalaxySave.getLastStarClicked()
	generatePlanetarySystem(posSeed)
