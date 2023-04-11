extends TextureButton
export var transferring = false

func _ready():
	get_node("../..").modulate.a = 0
	GalaxySave.setLastPlanetClicked(0,0)
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	$EnterLabel.text = "Enter\n" + str(relevantButtons)

func _on_EnterButton_pressed():
		if GalaxySave.getLastPlanetClicked() != 0:
			transferring = true
			update_ship_stats()
	# uses star position and position of planet to uniquely set up city pattern
			var _change = get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact"):
		if GalaxySave.getLastPlanetClicked() != 0:
			transferring = true
			update_ship_stats()
			# uses star position and position of planet to uniquely set up city pattern
			var _change = get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")

func update_ship_stats():
		GalaxySave.set_ship_speed(-1,true)
		GalaxySave.game_data["shipPosition"][6] = true
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation
