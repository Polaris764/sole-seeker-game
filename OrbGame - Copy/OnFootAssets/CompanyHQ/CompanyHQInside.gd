extends Node2D

export var playerPath : NodePath
onready var player = get_node(playerPath)
onready var ship_position = $Spaceship.global_position
onready var healStation = $YSort/HealStation
onready var storyPos = GalaxySave["game_data"]["storyProgression"]
onready var interaction_button = player.get_node("InteractionButton")
onready var landed_cam = $Spaceship/LandedCam
var visiting_controls = preload("res://MapUIs/General/FlightUIOverlay.tscn")

func _ready():
	if GalaxySave.game_data["shipPosition"][6]:
		player.queue_free()
		landed_cam.current = true
		var overlay = visiting_controls.instance()
		add_child(overlay)
	else:
		player.get_node("Camera2D").current = true
		player.global_position = ship_position + Vector2(37,-83)
		SignalBus.connect("updated_story",self,"handle_story")
		handle_story()

func handle_story():
	print("updating story")
	storyPos = GalaxySave["game_data"]["storyProgression"]
	set_atos_dialogue()
	if storyPos < 1:
		GalaxySave.game_data["shipPosition"][0] = get_station_position()
		healStation.healing()
		GalaxySave.game_data["storyProgression"] = 1
	elif storyPos == 3:
		$YSort/TrainingBot.active = true

func set_atos_dialogue():
	var stands = $YSort/AtosStands.get_children()
	for stand in stands:
		stand.get_node("DialogueArea").dialogue_key = "atos" + key_from_story_pos[GalaxySave.game_data["storyProgression"]]
		
var key_from_story_pos = {0:"1",1:"1",2:"2",3:"3",4:"4",5:"5", 6:"5",7:"5"}

#ship interaction
func _on_shipShape_body_entered(body):
	if body.name ==  "Player" and storyPos > 3:
		custom_interaction()
func _on_shipShape_body_exited(body):
	if body.name == "Player":
		interaction_button.areaLeft(self)
export var inside_ship_scene : NodePath = "res://OnFootAssets/InsideShip/InsideShip.tscn"
func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	interaction_button.updateButton(relevantButtons,"Enter Ship",self,"Interact")

func interacted():
	get_tree().change_scene(inside_ship_scene)

func get_station_position():
	var rngMach = RandomNumberGenerator.new()
	rngMach.seed = GalaxySave.game_data["galaxySeed"]
	var stationRadius = pow(rngMach.randi_range(10,20),2)
	var stationAngle = rngMach.randi_range(0,2*PI)
	return Vector2(cos(stationAngle)*stationRadius,sin(stationAngle)*stationRadius)
