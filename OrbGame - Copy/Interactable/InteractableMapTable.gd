extends Interactable

func get_interaction_text():
	return "View Map"
	
func interact():
	get_tree().change_scene("res://MapUIs/GalaxyMap.tscn")
