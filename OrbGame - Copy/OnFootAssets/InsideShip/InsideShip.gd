extends Node2D

onready var signalBus = SignalBus

func _ready():
	var storyPos = GalaxySave.game_data["storyProgression"]
	if storyPos < 5:
		start_tour()

func start_tour():
	signalBus.emit_signal("display_announcement","ship_tour1")
