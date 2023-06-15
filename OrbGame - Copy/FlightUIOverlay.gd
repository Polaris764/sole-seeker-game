extends CanvasLayer

onready var spaceship_level = GalaxySave.game_data["shipPosition"][2]

onready var spaceship_locations = ConstantsHolder.ship_locations

onready var current_spaceship_location = spaceship_locations.keys()[GalaxySave.game_data["shipPosition"][4]]

export var player : NodePath

func _ready():
#	print("space ship level: " + str(spaceship_level))
	if spaceship_level == 0:
		$IncreaseLabel.disabled_message = "Max Speed Reached"
	elif spaceship_level == -2:
		$DecreaseLabel.interaction_result = "Exit Flight Chair"
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
	elif storyPos == 13 and GalaxySave.game_data["totalKills"] > 24:
		GalaxySave.game_data["storyProgression"] = 14
	elif storyPos == 15:
		GalaxySave.game_data["storyProgression"] = 16
	elif storyPos == 16 and GalaxySave.game_data["totalKills"] > 34:
		GalaxySave.game_data["storyProgression"] = 17
	elif storyPos == 18 and GalaxySave.game_data["totalKills"] > 39:
		GalaxySave.game_data["storyProgression"] = 19
	elif storyPos == 19:
		GalaxySave.game_data["storyProgression"] = 20
	elif storyPos == 20:
		GalaxySave.game_data["storyProgression"] = 21

func _on_IncreaseLabel_interacted_with():
	set_ship_rotation()
	if GalaxySave.game_data["shipPosition"][4] == ConstantsHolder.ship_locations.STATION:
		GalaxySave.set_ship_speed(2)
	else:
		GalaxySave.set_ship_speed(1)


func _on_DecreaseLabel_interacted_with():
	set_ship_rotation()
	GalaxySave.set_ship_speed(-1)

func set_ship_rotation():
	GalaxySave.game_data["shipPosition"][3] = get_node("..").rotation
