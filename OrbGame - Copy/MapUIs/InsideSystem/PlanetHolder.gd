extends Node2D

export var planetPlace : int

var enlarged_Size = Vector2(1.2,1.2)

onready var systemTypeOptions = GalaxySave.getLastStarType()

func _ready():
	create_texture()
	self.position = get_viewport_rect().size/2

func _process(delta):
	#$Planet.margin_left = $Planet.margin_left * abs(cos(deg2rad(self.rotation))) create elipse
	var rotation_speed = 50/($Planet.margin_left*2)
	var rotation_speed2 = rand_range(.01,.03)
	self.rotation += delta*rotation_speed
	$Planet/PlanetImage.set_rotation($Planet/PlanetImage.get_rotation()+ delta*rotation_speed2)


func _on_Planet_pressed():
	print("planet pressed")
#	var childArray = get_node("..").get_children()
#	GalaxySave.setLastPlanetClicked(GalaxySave.getLastStarClicked(),childArray.find(self,0),self.modulate)
#	# uses star position and position of planet to uniquely set up city pattern
#	get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")


func _on_Area2D_body_entered(_body):
	updatePlanetInfoPanel(GalaxySave.getLastStarClicked())
	var childArray = get_node("..").get_children()
	GalaxySave.setLastPlanetClicked(GalaxySave.getLastStarClicked(),childArray.find(self,0),systemType)
	$Planet/PlanetImage.scale = enlarged_Size
	$Tween.stop_all()
	$Tween.interpolate_property(
		get_node("../../PlanetInfoHolder/Control"),
		'modulate:a',
		get_node("../../PlanetInfoHolder/Control").get_modulate().a,
		1,
		0.25,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	) # show info panel
	$Tween.call_deferred("start")

func _on_Area2D_body_exited(_body):
	if get_node("../../PlanetInfoHolder/Control/Holder/EnterButton").transferring == false:
		GalaxySave.setLastPlanetClicked(0,0)
	$Planet/PlanetImage/Area2D/SizeTween.interpolate_property($Planet/PlanetImage, "scale", enlarged_Size, Vector2(1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Planet/PlanetImage/Area2D/SizeTween.start()
	$Tween.stop_all()
	$Tween.interpolate_property(
		get_node("../../PlanetInfoHolder/Control"),
		'modulate:a',
		get_node("../../PlanetInfoHolder/Control").get_modulate().a,
		0.0,
		0.25,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	) # hide info panel
	$Tween.call_deferred("start")

var systemType = []
onready var planetImage = preload("res://MapUIs/InsideSystem/PlanetIcon.png")
func updatePlanetInfoPanel(seedUsed):
	var pPlanetImage = get_node("../../PlanetInfoHolder/Control/Holder/PlanetImage")
	var pPlanetName = get_node("../../PlanetInfoHolder/Control/Holder/PlanetName")
	var pOrbTypes = get_node("../../PlanetInfoHolder/Control/Holder/OrbTypes")
	var pPlanetBiome = get_node("../../PlanetInfoHolder/Control/Holder/BiomeType")
	var pPlanetButton = get_node("../../PlanetInfoHolder/Control/Holder/EnterButton")
	var pBookmarkButton = get_node("../../PlanetInfoHolder/Control/Holder/BookmarkButton")
	pPlanetButton.visible = true
	pBookmarkButton.visible = false
	var keyedSeed = str(pow(seedUsed*planetPlace,2)*cos(pow(seedUsed*planetPlace,3))).hash()
	seed(keyedSeed)
	var starName = GalaxySave.getLastStarClickedName()
	var alphabetOrder = {1:"a",2:"b",3:"c",4:"d",5:"e",6:"f",7:"g",8:"h",9:"i",10:"j",11:"k",12:"l",13:"m",14:"n",15:"o",16:"p",17:"q",18:"r",19:"s",20:"t",21:"u",22:"v",23:"w",24:"x",25:"y",26:"z",}
	pPlanetName.text = starName + " " + alphabetOrder[planetPlace]
	
	pPlanetImage.texture = planetImage
	var rng = RandomNumberGenerator.new()
	rng.seed = keyedSeed
	for _i in range(systemTypeOptions.size()):
		var picked = rng.randi()%(systemTypeOptions.size())
		if not systemType.has(systemTypeOptions[picked]):
			systemType.append(systemTypeOptions[picked])
		#systemTypeOptions.remove(picked)
	for _v in range(rng.randi_range(0,systemType.size())):
		systemType.remove(rng.randi()%systemType.size())
	if systemType.size() > 0:
		pOrbTypes.text = "Planet Type: " + array_join(systemType)
	else:
		pOrbTypes.text = "Planet Type: Uninhabited"

	rng.seed = keyedSeed
	var planetTypes = ["Marsh","Volcanic","Desert","Wet","Rust","Frozen"]
	var chosen_planet_type = planetTypes[rng.randi() % planetTypes.size()]
	pPlanetBiome.text = "Biome: " + chosen_planet_type

func array_join(arr, separator = ", "):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

const possible_ring_colors = [
"ddd9b6",
"968967",
"8e9174",
"fff3db",
"2d796d",
"4a5b39",
"8fa773",
"a4893c",
"a95414",
"deb87a",
"904a0f",
"07263b",
"5f808f",
"112c59",
"073a6f",
"9cb1c6"
]
func create_texture():
	var noise = OpenSimplexNoise.new()
	var seedUsed = GalaxySave.getLastStarClicked()
	var keyedSeed = str(pow(seedUsed*planetPlace,2)*cos(pow(seedUsed*planetPlace,3))).hash()
	var rng = RandomNumberGenerator.new()
	rng.seed = keyedSeed
	var planetTypes = ["Marsh","Volcanic","Desert","Wet","Rust","Frozen"]
	var chosen_planet_type = planetTypes[rng.randi() % planetTypes.size()]
	rng.seed = keyedSeed
	noise.seed = rng.randi()
	noise.octaves = 6
	noise.period = 120.0
	noise.persistence = 0.5
	var has_rings = rng.randi()%6
	match chosen_planet_type:
		"Desert":
			var img_texture = load("res://MapUIs/InsideSystem/DesertThumbnail.png")
			var img = img_texture.get_data()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
					if height > 20.0 and height < 21.0:
						img.set_pixel(x, y, Color("584731"))
					img.unlock()
			noise.seed = rng.randi()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
					if height > 20.0 and height < 21.0:
						img.set_pixel(x, y, Color("584731"))
					img.unlock()
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
		"Volcanic":
			var img_texture = load("res://MapUIs/InsideSystem/VolcanicThumbnail.png")
			var img = img_texture.get_data()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
					if height > 20.0 and height < 35.0:
						img.set_pixel(x, y, Color("242222"))
					img.unlock()
			noise.seed = rng.randi()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
					if height > 20.0 and height < 35.0 or height > 0 and height < 10:
						img.set_pixel(x, y, Color("242222"))
					img.unlock()
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
		"Marsh":
			var img_texture = load("res://MapUIs/InsideSystem/MarshThumbnail.png")
			var img = img_texture.get_data()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = sqrt(noise.get_noise_2d(x, y) * 60.0)  # MODIFY HERE FOR HEIGHT CHANGES
					if height > sqrt(5.0) and height < sqrt(7.0):
						img.set_pixel(x, y, Color("828500"))
					elif height > sqrt(7.0):
						img.set_pixel(x, y, Color("007300"))
					img.unlock()
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
		"Frozen":
			var img_texture = load("res://MapUIs/InsideSystem/FrozenThumbnail.png")
			var img = img_texture.get_data()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = sqrt(noise.get_noise_2d(x, y) * 60.0)  # MODIFY HERE FOR HEIGHT CHANGES
					if height > sqrt(0.0) and height < sqrt(15.0):
						img.set_pixel(x, y, Color("5d8260"))
					elif height > sqrt(15.0):
						img.set_pixel(x, y, Color("e7e8f6"))
					img.unlock()
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
		"Rust":
			var img_texture = load("res://MapUIs/InsideSystem/RustThumbnail.png")
			var img = img_texture.get_data()
			var crater_origins = {}
			for item in rng.randi_range(1,5):
				crater_origins[Vector2(rng.randi_range(0,64),rng.randi_range(0,64))] = rng.randi_range(3,9)
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = sqrt(noise.get_noise_2d(x, y) * 60.0)  # MODIFY HERE FOR HEIGHT CHANGES
					if height > sqrt(0.0) and height < sqrt(15.0):
						img.set_pixel(x, y, Color("aa4035"))
					for location in crater_origins:
						var distance = Vector2(x,y).distance_to(location)
						if distance < crater_origins[location]:
							img.set_pixel(x,y, Color("832b23"))
					img.unlock()
			# make craters
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
		"Wet":
			var img_texture = load("res://MapUIs/InsideSystem/WetThumbnail.png")
			var img = img_texture.get_data()
			for y in img.get_size().y:
				for x in img.get_size().x:
					img.lock()
					var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
					if height > 10.0:
						var color_used = rng.randi()%10
						if color_used < 8:
							img.set_pixel(x, y, Color("5d695d"))
						elif color_used == 8:
							img.set_pixel(x, y, Color("4f5d4f"))
						else:
							img.set_pixel(x, y, Color("717a71"))
					img.unlock()
			var texture = ImageTexture.new()
			texture.create_from_image(img)
			$Planet/PlanetImage.texture = texture
	if has_rings > 4:
		var img_texture = load("res://MapUIs/InsideSystem/RingTexture.png")
		var img = img_texture.get_data()
		var ring_parts = rng.randi()%3+1
		var ring_part_size = int(11/ring_parts)
		img.lock()
		for item in ring_parts:
			var is_visible = rng.randi()%3
			var color_chosen = possible_ring_colors[rng.randi()%possible_ring_colors.size()]
			if is_visible == 0:
				is_visible = 0
			else:
				is_visible = 1
			for pixel in ring_part_size:
				for number in 11:
					var colorValue = Color(color_chosen)
					colorValue.a = is_visible
					img.set_pixel(number, pixel+ring_part_size*item, colorValue)
					# implement alpha
		img.unlock()
		var texture = ImageTexture.new()
		texture.create_from_image(img)
		$Planet/PlanetImage/RingParticles.texture = texture
	else:
		$Planet/PlanetImage/RingParticles.queue_free()

# CODE FOR MULTICOLORED RINGS
#if true:#has_rings > 3:
#		var img_texture = load("res://MapUIs/InsideSystem/RingTexture.png")
#		var img = img_texture.get_data()
#		var ring_parts = rng.randi()%3+1
#		var ring_part_size = int(11/ring_parts)
#		img.lock()
#		for item in ring_parts:
#			var is_visible = rng.randi()%3
#			var color_chosen = possible_ring_colors[rng.randi()%possible_ring_colors.size()]
#			for pixel in ring_part_size:
#				for number in 11:
#					img.set_pixel(pixel+ring_part_size*item, number, Color(color_chosen))
#		img.unlock()
#		var texture = ImageTexture.new()
#		texture.create_from_image(img)
#		$Planet/PlanetImage/RingParticles.texture = texture

#CODE FOR SINGLE COLOR RINGS
#if true:#has_rings > 3:
#	var img_texture = load("res://MapUIs/InsideSystem/RingTexture.png")
#			var img = img_texture.get_data()
#			img.lock()
#			var color_chosen = possible_ring_colors[rng.randi()%possible_ring_colors.size()]
#			for x in 11:
#				for y in 11:
#					img.set_pixel(x,y, Color(color_chosen))
#			img.unlock()
#			var texture = ImageTexture.new()
#			texture.create_from_image(img)
#			$Planet/PlanetImage/RingParticles.texture = texture
