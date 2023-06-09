extends Node2D

export var ship_position : Vector2

var player
var interation_button

func _ready():
	create_planet()
	if GalaxySave.lastPlanetType:
		spawn_enemies()


func _on_Area2D_body_entered(body):
	if body.name ==  "Player":
		custom_interaction()


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		interation_button.areaLeft(self)

export var scene : NodePath = "res://OnFootAssets/InsideShip/InsideShip.tscn"
func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	interation_button.updateButton(relevantButtons,"Enter Ship",self,"Interact")

func interacted():
	if get_tree().change_scene(scene) != OK:
		print("error changing scenes")

var visiting_controls = preload("res://MapUIs/General/FlightUIOverlay.tscn")
var planet

onready var rng = RandomNumberGenerator.new()
func create_planet():
	var MarshWorld = ("res://OnFootAssets/MarshWorld.tscn")
	var VolcanicWorld = ("res://OnFootAssets/VolcanicWorld.tscn")
	var DesertWorld = ("res://OnFootAssets/DesertWorld.tscn")
	var WetWorld = ("res://OnFootAssets/WetWorld.tscn")
	var RustWorld = ("res://OnFootAssets/RustWorld.tscn")
	var FrozenWorld = ("res://OnFootAssets/FrozenWorld.tscn")
	var planetTypes = [MarshWorld,VolcanicWorld,DesertWorld,WetWorld,RustWorld,FrozenWorld]
	rng.seed = GalaxySave.getLastPlanetClicked()
	var chosen_planet_type = planetTypes[rng.randi() % planetTypes.size()]
	planet = load(chosen_planet_type).instance()
	add_child(planet)
	move_child(planet,0)
	#print("landing ship at " + str(ship_position))
	$Spaceship.global_position = ship_position
	$Shadow.global_position = ship_position
	var path = planet.name + "/Player" if planet.has_node("Player") else planet.name + "/YSort/Player"
	player = get_node(path)
	interation_button = player.get_node("InteractionButton")
	if GalaxySave.game_data["shipPosition"][6]:
		player.queue_free()
		$VisitingCamera.global_position = ship_position
		$VisitingCamera.current = true
		var overlay = visiting_controls.instance()
		add_child(overlay)
	else:
		player.global_position = ship_position + Vector2(83,37)
		var locator = player.get_node("UI/LocationMarker")
		locator.target_pos = ship_position
		locator.active = true
		if chosen_planet_type == WetWorld:
			player.slipperyGround = true

var red_enemy = preload("res://OnFootAssets/Enemies/RedOrb/RedOrb.tscn")
var blue_enemy = preload("res://OnFootAssets/Enemies/BlueOrb/BlueOrb.tscn")
var green_enemy = preload("res://OnFootAssets/Enemies/Purple/PurpleEnemy.tscn")
var orange_enemy = preload("res://OnFootAssets/Enemies/Orange/OrangeEnemy.tscn")
var black_enemy = preload("res://OnFootAssets/Enemies/Black/Black.tscn")
var purple_enemy = preload("res://OnFootAssets/Enemies/Round/Round.tscn")

var spawning_array
func spawn_enemies():
	spawning_array = planet.get_spawning_array()
	var enemies = GalaxySave.getLastPlanetType()
	if enemies.has("red"):
		spawn_red()
	if enemies.has("blue"):
		spawn_blue()
	if enemies.has("purple"):
		spawn_purple()
	if enemies.has("orange"):
		spawn_orange()
	if enemies.has("black"):
		spawn_black()
	if enemies.has("green"):
		spawn_green()
func spawn_red():
	print("spawning red")
	var spawn_location_count = rng.randi_range(5,15)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var group_size = rng.randi_range(2,4)
		for unit in group_size:
			var entity = red_enemy.instance()
			entity.global_position = location
			planet.get_node("YSort").add_child(entity)
func spawn_blue():
	print("spawning blue")
	var spawn_location_count = rng.randi_range(10,20)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var entity = blue_enemy.instance()
		entity.global_position = location
		planet.get_node("YSort").add_child(entity)
func spawn_purple():
	print("spawning purple")
	var spawn_location_count = rng.randi_range(2,4)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var entity = purple_enemy.instance()
		entity.global_position = location
		planet.get_node("YSort").add_child(entity)
func spawn_orange():
	print("spawning orange")
	var spawn_location_count = rng.randi_range(5,15)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var entity = orange_enemy.instance()
		entity.global_position = location
		planet.get_node("YSort").add_child(entity)
func spawn_black():
	print("spawning black")
	var spawn_location_count = rng.randi_range(10,20)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var group_size = rng.randi_range(8,16)
		for unit in group_size:
			var entity = black_enemy.instance()
			entity.global_position = location
			planet.get_node("YSort").add_child(entity)
func spawn_green():
	print("spawning green")
	var spawn_location_count = rng.randi_range(30,40)
	for spawn in spawn_location_count:
		var location = spawning_array[rng.randi()%spawning_array.size()] * Vector2(16,16) + Vector2(8,8)
		var group_size = rng.randi_range(8,16)
		for unit in group_size:
			var entity = green_enemy.instance()
			entity.global_position = location
			planet.get_node("YSort").add_child(entity)
