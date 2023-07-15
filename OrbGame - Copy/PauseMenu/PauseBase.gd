extends CanvasLayer

onready var menu_holder = get_node("..")

func _on_CloseButton_pressed():
	menu_holder.change_scene()
