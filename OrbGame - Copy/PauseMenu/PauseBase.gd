extends CanvasLayer

onready var menu_holder = get_node("..")

func _on_CloseButton_pressed():
	menu_holder.change_scene()

func _on_Inventory_pressed():
	menu_holder.change_scene(menu_holder.pause_inventory)

func _on_TravelLogs_pressed():
	menu_holder.change_scene(menu_holder.travel_logs)

func _on_EnemyHandbook_pressed():
	menu_holder.change_scene(menu_holder.enemy_handbook)

func _on_Quit_pressed():
	GalaxySave.save_data()
	get_tree().quit()

func initialize(): # necessary placeholder function
	pass
