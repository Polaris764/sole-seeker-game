extends CanvasLayer

onready var spaceship_level = GalaxySave.game_data["shipPosition"][2]

onready var spaceship_locations = ConstantsHolder.ship_locations

onready var current_spaceship_location = spaceship_locations.keys()[GalaxySave.game_data["shipPosition"][4]]

export var player : NodePath

onready var increase_label = $Holder/VBoxContainer/IncreaseLabel
onready var decrease_label = $Holder/VBoxContainer/DecreaseLabel

func _ready():
#	print("space ship level: " + str(spaceship_level))
	if spaceship_level == 0:
		increase_label.disabled_message = "Max Thrust Reached"
	elif spaceship_level == -2:
		decrease_label.interaction_result = "Exit Flight Chair"
	var storyPos = GalaxySave.game_data["storyProgression"]
	if storyPos == 5:
		SignalBus.emit_signal("display_announcement","first_ship_powered")
		GalaxySave.game_data["storyProgression"] = 6
	elif storyPos == 6:
		SignalBus.emit_signal("display_announcement","ship_guide1")
		GalaxySave.game_data["storyProgression"] = 7
	elif storyPos == 9:
		SignalBus.emit_signal("display_announcement","ship_guide4")
		GalaxySave.game_data["storyProgression"] = 10
	elif storyPos == 11 or storyPos == 12:
		GalaxySave.game_data["storyProgression"] = 13
	elif storyPos == 13 and GalaxySave.game_data["totalKills"] > ConstantsHolder.capture_1_kill_requirement:
		GalaxySave.game_data["storyProgression"] = 14
	elif storyPos == 15:
		GalaxySave.game_data["storyProgression"] = 16
	elif storyPos == 16 and GalaxySave.game_data["totalKills"] > ConstantsHolder.capture_2_kill_requirement:
		GalaxySave.game_data["storyProgression"] = 17
	elif storyPos == 18 and GalaxySave.game_data["totalKills"] > ConstantsHolder.cannon_proposal_kill_requirement:
		GalaxySave.game_data["storyProgression"] = 19
	elif storyPos == 19:
		GalaxySave.game_data["storyProgression"] = 20
	elif storyPos == 20:
		GalaxySave.game_data["storyProgression"] = 21
	elif storyPos == 22:
		if not ConstantsHolder.building_types.CANNON_POWER in GalaxySave.game_data["buildingData"]:
			GalaxySave.game_data["buildingData"][ConstantsHolder.building_types.CANNON_POWER] = []
		if GalaxySave.game_data["buildingData"][ConstantsHolder.building_types.CANNON_POWER].size() > 0:
			GalaxySave.game_data["storyProgression"] = 23

func _on_IncreaseLabel_interacted_with():
	set_ship_rotation()
	if GalaxySave.game_data["shipPosition"][4] == ConstantsHolder.ship_locations.STATION:
		GalaxySave.set_ship_speed(2)
	else:
		GalaxySave.set_ship_speed(1)


func _on_DecreaseLabel_interacted_with():
	set_ship_rotation()
	if GalaxySave.game_data["shipPosition"][4] != ConstantsHolder.ship_locations.PLANET:
		GalaxySave.game_data["shipPosition"][0] = get_node("..").global_position
	GalaxySave.set_ship_speed(-1)

func set_ship_rotation():
	GalaxySave.game_data["shipPosition"][3] = get_node("..").rotation
