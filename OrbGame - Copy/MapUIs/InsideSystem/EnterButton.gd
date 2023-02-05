extends TextureButton
export var transferring = false

func _ready():
	get_node("../..").modulate.a = 0
	GalaxySave.setLastPlanetClicked(0,0)

func _on_EnterButton_pressed():
		if GalaxySave.getLastPlanetClicked() != 0:
			transferring = true
	# uses star position and position of planet to uniquely set up city pattern
			get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact"):
		if GalaxySave.getLastPlanetClicked() != 0:
			transferring = true
			# uses star position and position of planet to uniquely set up city pattern
			get_tree().change_scene("res://OnFootAssets/InsideShip/InsideShip.tscn")
