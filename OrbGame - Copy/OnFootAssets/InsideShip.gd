extends Node2D

func _ready():
	$Player.isInShip = true
	$Door.scene = "res://OnFootAssets/VisitingPlanet.tscn"
