extends Node2D

onready var signalBus = SignalBus

func _ready():
	var storyPos = GalaxySave.game_data["storyProgression"]
	if storyPos < 5:
		start_tour()
	elif storyPos == 7:
		signalBus.emit_signal("display_announcement","ship_guide2")
		GalaxySave.game_data["storyProgression"] = 8
	elif storyPos == 8:
		if GalaxySave.game_data["backpackBlood"]["red"] > 0:
			signalBus.emit_signal("display_announcement","ship_guide3")
			GalaxySave.game_data["storyProgression"] = 9
		else:
			signalBus.emit_signal("display_announcement","ship_guide2.5")
	elif storyPos == 10:
		signalBus.emit_signal("display_announcement","ship_guide5")
		GalaxySave.game_data["storyProgression"] = 11

func start_tour():
	signalBus.emit_signal("display_announcement","ship_tour1")
