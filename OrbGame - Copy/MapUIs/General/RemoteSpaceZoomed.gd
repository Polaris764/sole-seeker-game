extends Node2D

func _ready():
	ConstantsHolder.leaving_map = false
	$Ship.rotation = GalaxySave.game_data["shipPosition"][3]
	$Ship/FlightUIOverlay/Holder/VBoxContainer/SpeedLabel.text = ""
