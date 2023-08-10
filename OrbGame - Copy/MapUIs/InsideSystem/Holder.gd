extends Container

onready var planet = preload("res://MapUIs/InsideSystem/PlanetHolder.tscn")
onready var starSprite = $Star
onready var starImage = preload("res://MapUIs/InsideSystem/starIcon.png")

var starAmountOptions = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,3,4]
var starType
var star_initial_size = Vector2(5,5)
func generatePlanetarySystem(seedUsed):
	var keyedSeed = pow(seedUsed,2)*cos(pow(seedUsed,3))
	seed(keyedSeed)
	var planetAmount
	if GalaxySave.game_data["gameModifications"]["megasystems"]:
		planetAmount = ConstantsHolder.megaPlanetAmountOptions[randi() % ConstantsHolder.megaPlanetAmountOptions.size()]
	else:
		planetAmount = ConstantsHolder.planetAmountOptions[randi() % ConstantsHolder.planetAmountOptions.size()]
	player.travel_distance = 600+600*planetAmount
	player.travel_distance_squared = pow(player.travel_distance,2)
	starType = starAmountOptions[randi() % starAmountOptions.size()]
	var particles = $Star/GeneralParticles
	match starType:
		1: #M d23b00
			starSprite.scale *= Vector2(.3,.3)
			star_initial_size *= Vector2(.3,.3)
			starSprite.material.set("shader_param/u_tolerance",0)
		2: #G
			starSprite.material.set("shader_param/u_replacement_color",Color("d17a1d"))
			particles.process_material.set("color_ramp",null)
			particles.process_material.color = Color("d17a1d")
			flare.process_material.set_color(Color("d17a1d"))
		3: #K
			starSprite.scale *= Vector2(.8,.8)
			star_initial_size *= Vector2(.8,.8)
			starSprite.material.set("shader_param/u_replacement_color",Color("eb6311"))
			particles.process_material.set("color","eb6311")
			flare.process_material.set("color","eb6311")
		4: #D
			starSprite.scale *= Vector2(.1,.1)
			star_initial_size *= Vector2(.1,.1)
			starSprite.material.set("shader_param/u_replacement_color",Color("ffffff"))
			particles.process_material.set("color","ffffff")
			flare.process_material.set("color","ffffff")
	for i in range(planetAmount):
		var radius = (i+1) * rand_range (400,600)
		var new_planet = planet.instance()
		new_planet.planetPlace = i+1
		add_child(new_planet)
		new_planet.position = $Star.global_position
		new_planet.get_node("Planet").margin_right = new_planet.get_node("Planet").margin_right + radius
		new_planet.get_node("Planet").margin_left = radius
		#warning-ignore:integer_division
		new_planet.set_rotation(deg2rad(rand_range(0,360)+Time.get_ticks_msec()/100))
		new_planet.get_node("Planet/PlanetImage").set_rotation(rand_range(0,360))
		#new_planet.get_node("Planet/PlanetImage").modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1)

onready var transScene = get_node("../TransitionScene")
onready var player = get_node("../Player")
func _ready():
	if ConstantsHolder.leaving_planet:
		transScene.queue_free()
	ConstantsHolder.leaving_planet = false
	set_process(false)
	get_node("../PlanetInfoHolder").visible = true
	var posSeed = GalaxySave.getLastStarClicked()
	generatePlanetarySystem(posSeed)
	player.global_position = GalaxySave.game_data["shipPosition"][1]
	if player.global_position == Vector2.ZERO:
		var angle = rng.randf_range(0,2*PI)
		player.global_position = Vector2(200,200)*Vector2(cos(angle),sin(angle))
	GalaxySave.game_data["shipPosition"][5] = true
	var planet_position = GalaxySave.game_data["shipPosition"][7]
	if planet_position > 0:
		player.global_position = get_children()[planet_position].get_node("Planet/PlanetImage").global_position
		planet_position = 0
		#print("setting at planet location. Player position = " + str(player.global_position) + ". Target planet = " + str(get_children()[planet_position]))
	GalaxySave.save_data()
	start_fTimer()
	if not trigger_end:
		player.functional = true
		transScene.emit_signal("load_complete")
	else:
		transScene.queue_free()

# star handling
var rng = RandomNumberGenerator.new()
onready var flare_timer = $Star/FlareTimer
onready var flare_holder = $Star/FlareHolder
onready var flare = $Star/FlareHolder/FlareParticles
export var flare_min = 8
export var flare_max = 20
func _on_FlareTimer_timeout():
	var random_angle = rng.randf_range(0,2*PI)
	var random_distance = rng.randf_range(25,34)*starSprite.scale.x
	flare_holder.global_position = Vector2(cos(random_angle),sin(random_angle))*Vector2(random_distance,random_distance)
	flare_holder.rotation = random_angle
	flare.emitting = true
	start_fTimer()

func start_fTimer():
	flare_timer.start(rand_range(flare_min,flare_max))


var enlarged_Size = Vector2(1.2,1.2)
func _on_StarArea_body_entered(_body):
	starSprite.scale = enlarged_Size*star_initial_size
	update_info_panel()
	$Star/Tween.stop_all()
	$Star/Tween.interpolate_property(
		get_node("../PlanetInfoHolder/Control"),
		'modulate:a',
		get_node("../PlanetInfoHolder/Control").get_modulate().a,
		1,
		0.25,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	) # show info panel
	$Star/Tween.call_deferred("start")

func _on_StarArea_body_exited(_body):
	$Star/Tween.interpolate_property(starSprite, "scale", enlarged_Size*star_initial_size, star_initial_size, .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Star/Tween.start()
	$Star/Tween.stop_all()
	$Star/Tween.interpolate_property(
		get_node("../PlanetInfoHolder/Control"),
		'modulate:a',
		get_node("../PlanetInfoHolder/Control").get_modulate().a,
		0.0,
		0.25,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	) # hide info panel
	$Star/Tween.call_deferred("start")

func update_info_panel():
	print(GalaxySave.game_data["bookmarkedStars"])
	var pPlanetImage = get_node("../PlanetInfoHolder/Control/Holder/PlanetImage")
	var pPlanetName = get_node("../PlanetInfoHolder/Control/Holder/PlanetName")
	var pOrbTypes = get_node("../PlanetInfoHolder/Control/Holder/OrbTypes")
	var pPlanetBiome = get_node("../PlanetInfoHolder/Control/Holder/BiomeType")
	var pPlanetButton = get_node("../PlanetInfoHolder/Control/Holder/EnterButton")
	var pBookmarkButton = get_node("../PlanetInfoHolder/Control/Holder/BookmarkButton")
	pPlanetButton.visible = false
	pBookmarkButton.visible = true
	var rng2 = RandomNumberGenerator.new()
	var keyedSeed = pow(GalaxySave.getLastStarClicked(),2)*cos(pow(GalaxySave.getLastStarClicked(),3))
	seed(keyedSeed)
	rng2.seed = keyedSeed
	pPlanetImage.texture = starImage
	pPlanetName.text = GalaxySave.getLastStarClickedName()
	var star_type
	var star_temp
	#var _planetAmount = planetAmountOptions[randi() % planetAmountOptions.size()]
	star_type = starAmountOptions[randi() % starAmountOptions.size()]
	match star_type:
		1:
			star_type = "Class M Star"
			star_temp = str(rng2.randi_range(2500,3500))
		2:
			star_type = "Class G Star"
			star_temp = str(rng2.randi_range(5000,6000))
		3:
			star_type = "Class K Star"
			star_temp = str(rng2.randi_range(3500,5000))
		4:
			star_type = "Class D Star"
			star_temp = str(rng2.randi_range(8000,40000))
	pOrbTypes.text = star_type
	pPlanetBiome.text = "Surface Temp: " + star_temp + " Kelvin"
	pPlanetButton.star = GalaxySave.getLastStarClickedName()
	pPlanetButton.star_pos = GalaxySave.game_data["shipPosition"][0]
	if GalaxySave.game_data["bookmarkedStars"].has(GalaxySave.getLastStarClickedName()) and GalaxySave.game_data["bookmarkedStars"][GalaxySave.getLastStarClickedName()] == GalaxySave.game_data["shipPosition"][0]:
		pBookmarkButton.get_node("BLabel").text = "Unbookmark"
		pPlanetButton.bookmarkable = false
	else:
		pPlanetButton.bookmarkable = true
		pBookmarkButton.get_node("BLabel").text = "Bookmark"

onready var camera = get_node("../SystemCamera")
onready var tween = get_node("../CamTween")
var trigger_end = false
func end_animation():
	var clouds = get_node("../Clouds/TextureRect")
	clouds.modulate.a = 1
	player.functional = false
	camera.zoom = Vector2(.1,.1)
	player.visible = false
	tween.interpolate_property(clouds,"modulate:a",1,0,1)
	tween.start()
	tween.interpolate_property(camera,"zoom",camera.zoom,Vector2(50,50),8,Tween.TRANS_EXPO)
	tween.start()
	yield(tween,"tween_all_completed")
	visible = false
	tween.interpolate_property(self,"modulate:a",1,0,1)
	tween.start()
	yield(tween,"tween_all_completed")
	var scene = load("res://MapUIs/GalaxyMap/GalaxyMap.tscn")
	var sceneI = scene.instance()
	sceneI.trigger_ending = true
	get_node("/root").add_child(sceneI)
	#sceneI.ending_scene()
	get_parent().queue_free()

onready var sTween = get_node("../ShipTween")
var planetTarget
func _on_EnterButton_entering_planet():
	player.functional = false
	planetTarget = get_children()[GalaxySave.game_data["shipPosition"][7]].get_node("Planet/PlanetImage")
	sTween.interpolate_property(player,"scale",player.scale,Vector2(.1,.1),2)
	sTween.start()
	sTween.interpolate_property(camera,"zoom",camera.zoom,Vector2(.2,.2),2)
	set_process(true)

func _on_ShipTween_tween_all_completed():
	get_node("../PlanetInfoHolder/Control/Holder/EnterButton").emit_signal("scene_switch")

func _process(delta):
	player.global_position = lerp(player.global_position, planetTarget.global_position, delta)
