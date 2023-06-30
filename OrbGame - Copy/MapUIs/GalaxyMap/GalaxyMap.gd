extends Node2D

onready var save_file = GalaxySave.game_data

var planet = preload("res://MapUIs/GalaxyMap/PlanetarySystem.tscn")
var HQ = preload("res://MapUIs/GalaxyMap/CompanyHQ.tscn")

onready var player = $Player
onready var camera = $GalaxyCamera

export var biomes = {"blue":[],"red":[],"orange":[],"purple":[],"black":[],"green":[],"white":[]}
export var biomes_collisions = {"blue":[],"red":[],"orange":[],"purple":[],"black":[],"green":[],"white":[]}

export var galaxy_size_var : float = 6

func rotatePoint(point,angle):
	var px = point*galaxy_size_var

	var qx = cos(angle) * (px) - sin(angle)*px
	var qy = sin(angle) * (px) + cos(angle)*px
	return Vector2(qx*rand_range(1,1.5-(.3*(px/4000))),qy*rand_range(.6,1.4))
	
func _ready():
	seed(save_file.galaxySeed) # player's saved world seed
	
	set_biome_circle_origins()
	set_biome_collisions()
	
	for _i in range(4000):
		# create a new instance of the planet scene
		var new_planet = planet.instance()
		# set its global_position to two random (float)
		# values lying somewhere between 0 and 400
		add_child(new_planet)
		var radius = pow(rand_range(0, 100),2)*galaxy_size_var
		var angle = rand_range(0, 2*PI)
		new_planet.global_position.x = cos(angle)*radius
		new_planet.global_position.y = sin(angle)*radius
		new_planet.system_type = determine_biome(Vector2(cos(angle)*radius,sin(angle)*radius))
	
	for i in range(0,5000):
		if i % 22 == 0:
			for _x in range(20):
				var new_planet = planet.instance()
				add_child(new_planet)
				var planet_pos = rotatePoint(i,i)
				new_planet.global_position = planet_pos
				new_planet.system_type = determine_biome(planet_pos)
	add_companyHQ()
	update_ship()
		

export var starsInside = []
onready var rngMach = RandomNumberGenerator.new()

var stationInstance
func add_companyHQ():
	var stationRadius = pow(rngMach.randi_range(10,20),2)
	var stationAngle = rngMach.randi_range(0,2*PI)
	stationInstance = HQ.instance()
	add_child(stationInstance)
	stationInstance.global_position = Vector2(cos(stationAngle)*stationRadius,sin(stationAngle)*stationRadius)

func update_ship():
	GalaxySave.game_data["shipPosition"][5] = false
	if GalaxySave.game_data["shipPosition"][0] == Vector2.ZERO:
		GalaxySave.game_data["shipPosition"][0] = stationInstance.global_position
	player.global_position = GalaxySave.game_data["shipPosition"][0]
	
func set_biome_circle_origins():
	rngMach.seed = GalaxySave.game_data["galaxySeed"]
	for amount in rngMach.randi_range(8,10):
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["blue"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
		if rngMach.randi()%2==0: biomes["blue"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(6,8):
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["red"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,4):
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["orange"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,3):
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["purple"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(2,12):
		var radius = rngMach.randi_range(500,10000)*galaxy_size_var
		var angle = rngMach.randf_range(0,2*PI)
		biomes["black"].append(Vector2(cos(angle),sin(angle))*Vector2(radius,radius))
	for amount in rngMach.randi_range(4,6):
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
			var circle_radius = rngMach.randi_range(300,1000)*galaxy_size_var
			var variance_radius = rngMach.randi_range(350,650)*galaxy_size_var
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
