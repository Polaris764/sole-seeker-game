extends Control

onready var planet = preload("res://MapUIs/InsideSystem/PlanetHolder.tscn")
var planetAmountOptions = [0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,10,11,12,13,14]
func generatePlanetarySystem(seedUsed):
	var keyedSeed = pow(seedUsed,2)*cos(pow(seedUsed,3))
	seed(keyedSeed)
	var planetAmount = planetAmountOptions[randi() % planetAmountOptions.size()]
	print(planetAmount)
	#$Camera2D.zoom = Vector2(planetAmount/3*2.5,planetAmount/3*2.5)
	#self.rect_size = Vector2(4096*7/planetAmount,2400*2/planetAmount)
	for i in range(planetAmount):
		yield(get_tree().create_timer(1.0), "timeout")
		var radius = (i+1) * rand_range (235,270)
		var new_planet = planet.instance()
		add_child(new_planet)
		new_planet.position = $Star.rect_global_position
		new_planet.get_node("Planet").margin_right = new_planet.get_node("Planet").margin_right + radius
		new_planet.get_node("Planet").margin_left = radius
		new_planet.set_rotation(rand_range(0,360))
		new_planet.get_node("Planet/PlanetImage").set_rotation(rand_range(0,360))
		new_planet.get_node("Planet/PlanetImage").modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1)
		

func _ready():
	var posSeed = GalaxySave.getLastStarClicked()
	generatePlanetarySystem(posSeed)
	start_fTimer()

func _on_Star_pressed():
	print("center star pressed")

var rng = RandomNumberGenerator.new()
onready var flare_timer = $FlareTimer
onready var flare_holder = $Star/FlareHolder
onready var flare = $Star/FlareHolder/FlareParticles
export var flare_min = 5
export var flare_max = 20
func _on_FlareTimer_timeout():
	var random_angle = rng.randf_range(0,2*PI)
	flare_holder.global_position = Vector2(cos(random_angle),sin(random_angle))*Vector2(32,32)
	flare_holder.rotation = random_angle
	flare.emitting = true
	start_fTimer()

func start_fTimer():
	print("showing items")
	flare_timer.start(rand_range(flare_min,flare_max))
