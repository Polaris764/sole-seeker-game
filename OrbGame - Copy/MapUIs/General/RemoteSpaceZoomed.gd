extends Node2D

func _ready():
	$Ship.rotation = GalaxySave.game_data["shipPosition"][3]
	$Ship/FlightUIOverlay/Holder/VBoxContainer/SpeedLabel.text = ""
