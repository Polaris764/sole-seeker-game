extends Interactable

func get_interaction_text():
	return "Exit Ship"
	
func interact():
	get_tree().change_scene("res://VillageBase.tscn")
