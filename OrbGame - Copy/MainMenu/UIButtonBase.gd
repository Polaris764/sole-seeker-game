extends Button

func _on_Button_mouse_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func _on_Button_mouse_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
