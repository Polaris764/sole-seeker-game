extends Node2D

export var ship_position : Vector2

var player
var interation_button

func _ready():
	create_planet()


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
	get_tree().change_scene(scene)

var visiting_controls = preload("res://MapUIs/General/FlightUIOverlay.tscn")

func create_planet():
	var MarshWorld = ("res://OnFootAssets/MarshWorld.tscn")
	var VolcanicWorld = ("res://OnFootAssets/VolcanicWorld.tscn")
	var DesertWorld = ("res://OnFootAssets/DesertWorld.tscn")
	var WetWorld = ("res://OnFootAssets/WetWorld.tscn")
	var RustWorld = ("res://OnFootAssets/RustWorld.tscn")
	var FrozenWorld = ("res://OnFootAssets/FrozenWorld.tscn")
	var planetTypes = [MarshWorld,VolcanicWorld,DesertWorld,WetWorld,RustWorld,FrozenWorld]
	seed(GalaxySave.getLastPlanetClicked())
	var chosen_planet_type = planetTypes[randi() % planetTypes.size()]
	var planet = load(chosen_planet_type).instance()
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
		if chosen_planet_type == WetWorld:
			player.slipperyGround = true
		
