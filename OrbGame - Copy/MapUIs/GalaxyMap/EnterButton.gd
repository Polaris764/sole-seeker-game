extends TextureButton

onready var starNameLabel = get_node("../StarName")

func _ready():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	$EnterLabel.text = "Enter\n" + str(relevantButtons)

func _on_EnterButton_pressed():
	var currentStar = get_node("../../../..").starsInside[0]
	GalaxySave.setLastStarClicked(currentStar.global_position,starNameLabel.text)
	if currentStar.CompanyStation == true:
		update_ship_stats(true)
		get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn") ## transport to company scene
	else:
		update_ship_stats(false)
		get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact") and get_node("../../../..").starsInside.size() > 0:
		var currentStar = get_node("../../../..").starsInside[0]
		print(currentStar)
		GalaxySave.setLastStarClicked(currentStar.global_position,starNameLabel.text)
		if currentStar.CompanyStation == true:
			update_ship_stats(true)
			get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn") ## transport to company scene
		else:
			update_ship_stats(false)
			get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
			
func update_ship_stats(companyStation):
	if companyStation:
		GalaxySave.set_ship_speed(-2,true)
		GalaxySave.game_data["shipPosition"][6] = true
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation
	else:
		GalaxySave.set_ship_speed(-1,true)
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation
