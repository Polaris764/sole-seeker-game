extends CanvasLayer

onready var menu_holder = get_node("..")

func _on_CloseButton_pressed():
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
	menu_holder.change_scene()

func _on_Inventory_pressed():
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	menu_holder.change_scene(menu_holder.pause_inventory)

func _on_TravelLogs_pressed():
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	menu_holder.change_scene(menu_holder.travel_logs)

func _on_EnemyHandbook_pressed():
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	menu_holder.change_scene(menu_holder.enemy_handbook)

func _on_Quit_pressed():
	if not ConstantsHolder.saving_disabled:
		GalaxySave.save_data()
	get_tree().quit()

func _on_Save_pressed():
	if not ConstantsHolder.saving_disabled:
		GalaxySave.save_data()

var menuScene = "res://MainMenu/UIHolder.tscn"
func _on_MainMenu_pressed():
	get_tree().paused = false
	var change = get_tree().change_scene(menuScene)
	if change != OK:
		print(change)

func initialize(): # necessary placeholder function
	pass

func _ready():
	if ConstantsHolder.saving_disabled:
		$Save.disabled = true
