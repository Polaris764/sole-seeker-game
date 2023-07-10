extends Node

var current_screen = null
onready var mainUI = $MainUI
onready var settingsUI = $SettingsUI
onready var newgameUI = $NewGameUI

func _ready():
	register_buttons()
	change_screen(mainUI)

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		button.connect("pressed",self,"on_button_pressed",[button.name])

func change_screen(new_screen = null):
	if current_screen:
		current_screen.disappear()
		yield(current_screen.tween,"tween_all_completed")
	current_screen = new_screen
	if new_screen:
		current_screen.appear()
		yield(current_screen.tween,"tween_all_completed")

func on_button_pressed(name):
	match name:
		# Main Buttons
		"LoadSaveButton":
			change_screen()
		"NewGameButton":
			change_screen(newgameUI)
		"SettingsButton":
			change_screen(settingsUI)
		"BackButton":
			change_screen(mainUI)
		# New Game Buttons
		"CreateButton":
			create_new_save()
				
# New Game Code

func create_new_save():
	var save_name
	GalaxySave.SAVE_FILE = "user://save_file_" + save_name + ".save"
