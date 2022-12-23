extends Node2D

onready var save_file = GalaxySave.game_data

var planet = preload("res://MapUIs/GalaxyMap/PlanetarySystem.tscn")
var HQ = preload("res://MapUIs/GalaxyMap/CompanyHQ.tscn")

func rotatePoint(point,angle):
	var px = point

	var qx = cos(angle) * (px) - sin(angle)*px
	var qy = sin(angle) * (px) + cos(angle)*px
	return Vector2(qx*rand_range(1,1.5-(.3*(px/4000))),qy*rand_range(.6,1.4))
	
func _ready():
	
	seed(save_file.galaxySeed) # player's saved world seed
	
	for _i in range(4000):
		# create a new instance of the planet scene
		var new_planet = planet.instance()
		# set its global_position to two random (float)
		# values lying somewhere between 0 and 400
		add_child(new_planet)
		var radius = pow(rand_range(0, 100),2)
		var angle = rand_range(0, 2*PI)
		new_planet.global_position.x = cos(angle)*radius
		new_planet.global_position.y = sin(angle)*radius
	
	for i in range(0,10000):
		if i %22 == 0:
			for _x in range(20):
				var new_planet = planet.instance()

				add_child(new_planet)
				new_planet.global_position = rotatePoint(i,i)

	add_companyHQ()
export var starsInside = []

func add_companyHQ():
	var stationRadius = pow(rand_range(10,20),2)
	var stationAngle = rand_range(0,2*PI)
	var stationInstance = HQ.instance()
	add_child(stationInstance)
	stationInstance.global_position = Vector2(cos(stationAngle)*stationRadius,sin(stationAngle)*stationRadius)
