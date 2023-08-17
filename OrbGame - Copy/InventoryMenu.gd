extends Control

onready var resource_label = $NinePatchRect/ResourcesLabel
onready var building_label = $NinePatchRect/BuildingsLabel

func _ready():
	refresh_values()

#func _process(_delta):
#	if Input.is_action_just_released("inventory"):
#		visible = not visible
#		refresh_values()

func refresh_values():
	resource_label.text = "Red Orbs: " + str(GalaxySave.game_data["backpackBlood"]["red"]) + "\nBlue Orbs: " + str(GalaxySave.game_data["backpackBlood"]["blue"])
	var building_label_text : String = ""
	for item in GalaxySave.game_data["storedBuildings"]:
		building_label_text += str(ConstantsHolder.building_types.keys()[item]) + ": " + str(GalaxySave.game_data["storedBuildings"][item]) + "\n"
	building_label.text = building_label_text
