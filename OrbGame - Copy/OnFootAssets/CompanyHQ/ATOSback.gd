extends Sprite

func _on_Interactable_interacted_with():
	ConstantsHolder.update_story_from_atos()
