extends Node2D

onready var save_file = GalaxySave.game_data

var planet = preload("res://MapUIs/GalaxyMap/PlanetarySystem.tscn")
var HQ = preload("res://MapUIs/GalaxyMap/CompanyHQ.tscn")

onready var player = $Player
onready var camera = $GalaxyCamera

export var biomes = {"blue":[],"red":[],"orange":[],"purple":[],"black":[],"green":[],"white":[]}
export var biomes_collisions = {"blue":[],"red":[],"orange":[],"purple":[],"black":[],"green":[],"white":[]}

onready var galaxy_size_var : float = ConstantsHolder.galaxy_size_var

var Tinstance
var coverInstance
func _ready():
	AudioManager.play_song([AudioManager.songs.delusional,AudioManager.songs.universe,AudioManager.songs.drifting],"galaxyMap")
	AudioManager.stop_song("deepSpace")
	if not trigger_ending:
		var Tscene = preload("res://UIResources/TransitionScene.tscn")
		Tinstance = Tscene.instance()
		get_node("/root").add_child(Tinstance)
	else:
		var cScene = preload("res://MapUIs/Theme/GalaxyBackground.tscn")
		coverInstance = cScene.instance()
		get_node("/root").add_child(coverInstance)
	start()

func start():
	seed(save_file.galaxySeed) # player's saved world seed
	set_biome_circle_origins()
	set_biome_collisions()
	var rng = RandomNumberGenerator.new()
	rng.seed = (save_file.galaxySeed)
	for i in range(4000):
		if i % 100 == 0: 
			yield(get_tree(), "idle_frame")
		# create a new instance of the planet scene
		var new_planet = planet.instance()
		# set its global_position to two random (float)
		# values lying somewhere between 0 and 400
		add_child(new_planet)
		var radius = pow(rng.randf_range(2, 100),2)*galaxy_size_var
		var angle = rng.randf_range(0, 2*PI)
		new_planet.global_position.x = (cos(angle)*radius)
		new_planet.global_position.y = (sin(angle)*radius)
		new_planet.system_type = determine_biome(Vector2(cos(angle)*radius,sin(angle)*radius))
	var possible_arms = [0]#[0,11,7,12]
#	for i in rand_range(0,3):
#		possible_arms.pop_at(rand_range(0,possible_arms.size()-1))
	for i in range(0,10000):
		if i % 100 == 0: 
			yield(get_tree(), "idle_frame")
		if possible_arms.has(i % 22):
			for _x in range(20):
				var new_planet = planet.instance()
				add_child(new_planet)
				var planet_pos = ConstantsHolder.rotatePoint(i,i,rng)
				new_planet.global_position = Vector2(planet_pos.x,planet_pos.y)#planet_pos
				new_planet.system_type = determine_biome(planet_pos)
	add_companyHQ()
	update_ship()
	camera.current = true
	if Tinstance:
		Tinstance.emit_signal("load_complete")
	if trigger_ending:
		ending_scene()

func _exit_tree():
	AudioManager.stop_song("galaxyMap")

export var starsInside = []
onready var rngMach = RandomNumberGenerator.new()

var stationInstance
func add_companyHQ():
	var rngMachStation = RandomNumberGenerator.new()
	rngMachStation.seed = GalaxySave.game_data["galaxySeed"]
	var stationRadius = pow(rngMachStation.randi_range(10,20),2)
	var stationAngle = rngMachStation.randi_range(0,2*PI)
	stationInstance = HQ.instance()
	add_child(stationInstance)
	stationInstance.global_position = Vector2(cos(stationAngle)*stationRadius,sin(stationAngle)*stationRadius)

func update_ship():
	GalaxySave.game_data["shipPosition"][5] = false
	if GalaxySave.game_data["shipPosition"][0] == Vector2.ZERO:
		GalaxySave.game_data["shipPosition"][0] = stationInstance.global_position
	player.global_position = GalaxySave.game_data["shipPosition"][0]
	if not trigger_ending:
		player.functional = true
	
func set_biome_circle_origins():
	rngMach.seed = GalaxySave.game_data["galaxySeed"]
	var population_multiplier = 1
	if GalaxySave.game_data["gameModifications"]["populationBoom"]:
		population_multiplier = 4
	for amount in rngMach.randi_range(8,10)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["blue"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
		if rngMach.randi()%2==0: biomes["blue"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(6,8)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["red"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,4)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["orange"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,3)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["purple"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,12)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["black"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(4,6)*population_multiplier:
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["green"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in 1:
		var radius = rngMach.randi_range(9000,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["white"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))

var collision_scene = preload("res://MapUIs/GalaxyMap/SystemTypeCollision.tscn")
func set_biome_collisions():
	for biome_type in biomes:
		for location in biomes[biome_type]:
			var cosine_length_options = [3,5]
			var cosine_length2_options = [4,6]
			var sin_length_options = [7,9,11,13]
			var point_count = 200
			var circle_radius = rngMach.randi_range(300,1000)*galaxy_size_var*2
			var variance_radius = rngMach.randi_range(350,650)*galaxy_size_var*2
			var cosine_length = cosine_length_options[rngMach.randi() % cosine_length_options.size()]
			var cosine_length2 = cosine_length2_options[rngMach.randi() % cosine_length2_options.size()]
			var sin_length = sin_length_options[rngMach.randi() % sin_length_options.size()]
			var hori_stretch = rngMach.randf_range(1,2)
			var vert_stretch = rngMach.randf_range(1,2)
			var collision = collision_scene.instance()
			var ptArray = PoolVector2Array()
			if biome_type == "white":
				circle_radius = rngMach.randi_range(1500,2000)*galaxy_size_var
			for point in point_count:
				var circle_radius2 = circle_radius + variance_radius*cos(cosine_length*PI*point/point_count)*sin(sin_length*PI*point/point_count)*cos(cosine_length2*PI*point/point_count)# + 100*cos(2*PI*point/100)
				var point_angle = (2*PI)/point_count*point
				ptArray.append(location + Vector2(hori_stretch*cos(point_angle),vert_stretch*sin(point_angle))*Vector2(circle_radius2,circle_radius2))
			collision.polygon = ptArray
			if biome_type == "white" and trigger_ending:
				white_array = ptArray
			if not Geometry.triangulate_polygon(ptArray) == PoolIntArray(): # check for invalid polygon
				#coloration
				collision.draw_array = ptArray
				collision.biome_type = biome_type
				biomes_collisions[biome_type].append(collision)
				add_child(collision)

func determine_biome(system_pos):
	var system_types = []
	for biome_type in biomes_collisions:
		for collision_polygon in biomes_collisions[biome_type]:
			if Geometry.is_point_in_polygon(system_pos,collision_polygon.polygon):
				if not system_types.has(biome_type):
					system_types.append(biome_type)
	return system_types

enum collision_visibility {
	NONE,
	ALL,
	RED,
	BLUE,
	PURPLE,
	ORANGE,
	BLACK,
	GREEN,
	WHITE
}
var visibile_collision = collision_visibility.NONE
var visible_transparency_float : float = .5
func _process(_delta):
	if Input.is_action_just_pressed("build_state_switch"):
		visibile_collision += 1
		if visibile_collision > collision_visibility.size()-1:
			visibile_collision = 0
		for color in biomes_collisions:
			for collision in biomes_collisions[color]:
				collision.transparency = 0
				var normalized_CV = str(collision_visibility.keys()[visibile_collision]).to_lower()
				if normalized_CV == color or normalized_CV == "all":
					collision.transparency = visible_transparency_float
	if trigger_ending and Input.is_action_just_pressed("Interact"):
		get_tree().set_input_as_handled()
		SignalBus.emit_signal("display_dialogue","ending_dialogue")

onready var tween = $Tween
var trigger_ending = false
var white_array
var laserInstance
var laserInstance2
func ending_scene():
	player.visible = false
	$SystemInfo.visible = false
	visible = true
	camera.zoom = Vector2(.1,.1)
	tween.interpolate_property(camera,"zoom",camera.zoom,Vector2(100,100),5,Tween.TRANS_CUBIC)
	tween.start()
	var laserPolygon = load("res://OnFootAssets/EndSequence/LaserPolygon.tscn")
	laserInstance = laserPolygon.instance()
	laserInstance.modulate.a = 0
	tween.interpolate_property(laserInstance,"modulate:a",0,1,15,Tween.TRANS_EXPO)
	tween.start()
	#print(white_array)
	var cannonPos = GalaxySave.game_data["cannonLocation"]
	var rng = RandomNumberGenerator.new()
	var laserTarget = rng.randi_range(0,white_array.size()-1)
	var laserArray = [cannonPos,white_array[laserTarget-2],white_array[laserTarget+2]]
	laserInstance.polygon = white_array
	add_child(laserInstance)
	laserInstance2 = laserPolygon.instance()
	laserInstance2.modulate.a = 0
	laserInstance2.polygon = laserArray
	add_child(laserInstance2)
	tween.interpolate_property(laserInstance2,"modulate:a",0,1,15,Tween.TRANS_EXPO)
	tween.start()
	var dialogue = load("res://OnFootAssets/DialogueSystem/DialogueLayer.tscn")
	var dialogue_instance = dialogue.instance()
	dialogue_instance.pause_while_showing = false
	add_child(dialogue_instance)
	SignalBus.emit_signal("display_dialogue","ending_dialogue")
	dialogue_instance.get_node("Background").connect("visibility_changed",self,"monologue_over")
	if coverInstance:
		coverInstance.queue_free()

func monologue_over():
	print("monologue over")
	tween.interpolate_property($Fader/ColorRect,"modulate:a",0,1,2)
	tween.start()
	yield(tween,"tween_completed")
	get_tree().current_scene = self
	var _new_scene = get_tree().change_scene("res://MainMenu/UIHolder.tscn")

var laser_ended = false
func _on_Tween_tween_all_completed():
	if not laser_ended:
		laser_ended = true
		tween.interpolate_property(laserInstance,"modulate:a",1,0,15,Tween.TRANS_EXPO)
		tween.start()
		tween.interpolate_property(laserInstance2,"modulate:a",1,0,15,Tween.TRANS_EXPO)
		tween.start()
