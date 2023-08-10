extends "res://PauseMenu/PauseBase.gd"

onready var backpack = $VBoxContainer/Backpack
onready var stored = $VBoxContainer/Station

func initialize():
	var resources_string1 = "Carried Resources: "
	var backpackB = GalaxySave.game_data["backpackBlood"]
	for i in backpackB:
		resources_string1 += ("\n" + str(i).capitalize()+": "+str(backpackB[i]))
	backpack.text = resources_string1
	var resources_string2 = "Stored Resources: "
	var storedB = GalaxySave.game_data["storedBlood"]
	for i in storedB:
		resources_string2 += ("\n" + str(i).capitalize()+": "+str(storedB[i]))
	stored.text = resources_string2
