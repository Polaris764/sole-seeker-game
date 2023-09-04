extends TextureButton

func _ready():
	if not name in GalaxySave.game_data["enemiesContacted"]:
		disabled = true
		visible = false
		
func _on_OrganismButton_mouse_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func _on_OrganismButton_mouse_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
