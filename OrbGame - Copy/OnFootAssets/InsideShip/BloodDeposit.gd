extends Node2D


func _ready():
	print(GalaxySave.game_data["backpackBlood"])
func _on_Interactable_interacted_with():
	for child in GalaxySave.game_data["backpackBlood"]:
		GalaxySave.game_data["storedBlood"][child] += GalaxySave.game_data["backpackBlood"][child]
		GalaxySave.game_data["backpackBlood"][child] = 0
	GalaxySave.save_data()
