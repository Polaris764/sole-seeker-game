extends Node2D

func _ready():
	$Ship.rotation = GalaxySave.game_data["shipPosition"][3]
