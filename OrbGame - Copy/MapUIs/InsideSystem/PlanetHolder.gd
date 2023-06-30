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

func create_texture():
	var noise = OpenSimplexNoise.new()
	var img = Image.new()
	img.create(64,64, false, Image.FORMAT_RGBA8)
	
	# Noise properties
	randomize() # Needed for random each time
	# CHANGE THESE FOR NOISE VARIATION
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 120.0
	noise.persistence = 0.5
	
	for y in img.get_size().y:
		for x in img.get_size().x:
			img.lock()
			var height = noise.get_noise_2d(x, y) * 60.0  # MODIFY HERE FOR HEIGHT CHANGES
			if height < 0.0:
				img.set_pixel(x, y, Color(0.380, 0.509, 0.980))
			elif height >= 0.0 and height < 5.0:
				img.set_pixel(x, y, Color(0.882, 0.862, 0.576))
			elif height >= 5.0 and height < 25.0:
				img.set_pixel(x, y, Color(0.611, 0.882, 0.576))
			elif height >= 25.0:
				img.set_pixel(x, y, Color(0.533, 0.549, 0.529))
				img.unlock()
	
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	$Planet/PlanetImage.material.set_shader_param("TextureMap", texture)
