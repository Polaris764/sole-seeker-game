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
	AudioManager.play_song([AudioManager.songs.release],"station")
	player.get_node("FootstepAudio").stream = load("res://Audio/Footsteps/tile_footsteps.wav")
	if GalaxySave.game_data["shipPosition"][6]:
		player.queue_free()
		landed_cam.current = true
		var overlay = visiting_controls.instance()
		add_child(overlay)
	else:
		cover.modulate.a = 1
		player.get_node("Camera2D").current = true
		player.global_position = ship_position + Vector2(37,-83)
		var _val = SignalBus.connect("updated_story",self,"handle_story")
		handle_story()
		tween.interpolate_property(cover,"modulate:a",1,0,.5)
		tween.start()

func _exit_tree():
	AudioManager.stop_song("station")
func handle_story():
	print("updating story")
	storyPos = GalaxySave["game_data"]["storyProgression"]
	print(storyPos)
	set_atos_dialogue()
	if storyPos < 1:
		GalaxySave.game_data["shipPosition"][0] = get_station_position()
		healStation.healing()
		$BackupCamera.global_position = healStation.get_node("Position2D2").global_position
	elif storyPos == 2:
		$YSort/TrainingDoor.locked = true
	elif storyPos == 3:
		$YSort/TrainingBot.active = true
	elif storyPos == 4:
		$YSort/TrainingDoor.locked = false
	elif storyPos >= 11:
		$YSort/ShopDoor.locked = false
	elif storyPos >= 15:
		if not "White" in GalaxySave.game_data["enemiesContacted"]:
			GalaxySave.game_data["enemiesContacted"].append("White")
	elif storyPos == 21:
		SignalBus.emit_signal("display_announcement","cannon_audience")

func set_atos_dialogue():
	var stands = $YSort/AtosStands.get_children()
	for stand in stands:
		stand.get_node("DialogueArea").dialogue_key = "atos" + key_from_story_pos[GalaxySave.game_data["storyProgression"]]
		
var key_from_story_pos = {0:"0",1:"1",2:"2",3:"3",4:"4",5:"5",6:"5",7:"5",8:"5",9:"5",10:"5",11:"11",12:"12",13:"13",14:"14",15:"15",16:"16",17:"17",18:"18",19:"18",20:"18",21:"21",22:"21",23:"23",24:"23"}

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

onready var cover = $TransitionCover/ColorRect
onready var tween = $TransitionCover/Tween
func interacted():
	ConstantsHolder.leaving_map = false
	tween.interpolate_property(cover,"modulate:a",0,1,.5)
	tween.start()
	yield(tween,"tween_completed")
	var _change = get_tree().change_scene(inside_ship_scene)

func get_station_position():
	var rngMach = RandomNumberGenerator.new()
	rngMach.seed = GalaxySave.game_data["galaxySeed"]
	var stationRadius = pow(rngMach.randi_range(10,20),2)
	var stationAngle = rngMach.randi_range(0,2*PI)
	return Vector2(cos(stationAngle)*stationRadius,sin(stationAngle)*stationRadius)
