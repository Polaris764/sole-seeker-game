extends TextureButton

onready var starNameLabel = get_node("../StarName")

func _on_EnterButton_pressed():
	var currentStar = get_node("../../../..").starsInside[0]
	GalaxySave.setLastStarClicked(currentStar.global_position.x,starNameLabel.text)
	get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact") and get_node("../../../..").starsInside.size() > 0:
		var currentStar = get_node("../../../..").starsInside[0]
		print(currentStar)
		GalaxySave.setLastStarClicked(currentStar.global_position.x,starNameLabel.text)
		if currentStar.CompanyStation == true:
			get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn") ## transport to company scene
		else:
			get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn")
