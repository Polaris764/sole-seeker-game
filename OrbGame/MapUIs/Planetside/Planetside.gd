extends Node2D

var cityAmountOptions = [0,1,1,2,2,2,3,3,3,4,4,4,5,5,6]
onready var city = preload("res://MapUIs/Planetside/CityHolder.tscn")

func spawn_city_items(amountToSpawn):
	#yield(get_tree().create_timer(30.0), "timeout")
	var city_items = []
	for _i in range(amountToSpawn):
		var x = 0
		var y = 0
		var too_close = true
		while(too_close):
			x = rand_range($PlanetGround/ParallaxLayer/Sprite.position.x,$PlanetGround/ParallaxLayer/Sprite.position.x + $PlanetGround/ParallaxLayer/Sprite.texture.get_width() - 100)
			y = rand_range($PlanetGround/ParallaxLayer/Sprite.position.y,$PlanetGround/ParallaxLayer/Sprite.position.y + $PlanetGround/ParallaxLayer/Sprite.texture.get_height())
			too_close = false
			for item in city_items:
				var other_pos = item.get_position()
				var x_diff = abs(x - other_pos.x)
				var y_diff = abs(y - other_pos.y)
				if x_diff < 32 && y_diff < 32:
					too_close = true
					break
		var instance = city.instance()
		instance.set_position(Vector2(x, y))
		city_items.push_back(instance)
	for i in city_items:
		$PlanetGround/ParallaxLayer.add_child(i)
	
func generatePlanetSurface(seedUsed):
	var keyedSeed = pow(seedUsed,2)*cos(pow(seedUsed,3))
	seed(keyedSeed)
	var cityAmount = cityAmountOptions[randi() % cityAmountOptions.size()]
	print(cityAmount)
	spawn_city_items(cityAmount)

func _ready():
	var planetCode = GalaxySave.getLastPlanetClicked()
	print("planet code:")
	print(planetCode)
	#generatePlanetSurface(planetCode)
