extends Node

var current_screen = null
onready var mainUI = $MainUI
onready var settingsUI = $SettingsUI
onready var newgameUI = $NewGameUI
onready var loadsaveUI = $LoadSave

func _ready():
	AudioManager.play_song([AudioManager.songs.preparation],"mainMenu")
	setup_custom_configs()
	register_buttons()
	change_screen(mainUI)
	initialize_newGame_scene()

func _exit_tree():
	AudioManager.stop_song("mainMenu")
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
	AudioManager.play_effect([AudioManager.effects.menuClick])
	match name:
		# Main Buttons
		"LoadSaveButton":
			change_screen(loadsaveUI)
		"NewGameButton":
			change_screen(newgameUI)
		"SettingsButton":
			change_screen(settingsUI)
		"QuitButton":
			get_tree().quit()
		"BackButton":
			change_screen(mainUI)
		# New Game Buttons
		"CreateButton":
			create_new_save()
				
# New Game Code

onready var nameLineEditor = $NewGameUI/MarginContainer/MenuContainer/NameHolder/TextEditor
func initialize_newGame_scene():
	nameLineEditor.placeholder_text = file_name_to_save_name(pick_next_save_name())

func create_new_save():
	var save_name : String
	if nameLineEditor.text.empty():
		save_name = pick_next_save_name()
	else:
		save_name = "save_file-" + nameLineEditor.text.replace(" ","_") + "-.save"
	GalaxySave.SAVE_FILE = save_name
	GalaxySave.load_data()
	var seedLineEditor = $NewGameUI/MarginContainer/MenuContainer/SeedHolder/TextEditor
	if seedLineEditor.text.empty():
		GalaxySave.game_data["galaxySeed"] = randi()
	else:
		GalaxySave.game_data["galaxySeed"] = seedLineEditor.text
	for button in $NewGameUI/MarginContainer/MenuContainer/NewGameContainer.get_children():
		if button.selected == true:
			GalaxySave.game_data["gameModifications"][button.name] = true
		else:
			GalaxySave.game_data["gameModifications"][button.name] = false
	GalaxySave.save_data()
	start_game(save_name)

func list_file_count_in_directory(path):
	var files = 0
	var dir = Directory.new()
	if not dir.dir_exists(GalaxySave.SAVE_FILE_PATH):
		dir.make_dir(GalaxySave.SAVE_FILE_PATH)
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.begins_with("save_file"):
			files += 1
	return files

func pick_next_save_name():
	var starting_number = list_file_count_in_directory(GalaxySave.SAVE_FILE_PATH) + 1
	var file = File.new()
	while true:
		var try = "save_file_default-" + str(starting_number) + "-.save"
		if file.file_exists(GalaxySave.SAVE_FILE_PATH+try):
			starting_number += 1
		else:
			return try

func file_name_to_save_name(file_name : String):
	if "save_file_default-" in file_name:
		return "Game " + file_name.split("-")[-2]
	else:
		return file_name.split("-")[-2].replace("_"," ")

func start_game(file_name):
	GalaxySave.SAVE_FILE = file_name
	GalaxySave.load_data()
	GalaxySave.start_game()

var custom_configs
var configs_file = "user://configs.json"
signal configs_updated
func setup_custom_configs():
	var file = File.new()
	
	if not file.file_exists(configs_file):
		custom_configs = {
			"default_controls":{},
			"controls":{},
			"musicVolume":-10,
			"SFXVolume":-10
		}
		for item in ConstantsHolder.customizable_controls:
			if "scancode" in InputMap.get_action_list(item)[0]:
				custom_configs["default_controls"][item] = [InputMap.get_action_list(item)[0].scancode,"InputEventKey"]
			else:
				custom_configs["default_controls"][item] = [InputMap.get_action_list(item)[0].button_index,"InputEventMouseButton"]
		save_configs()
	file.open(configs_file,File.READ)
	custom_configs = JSON.parse(file.get_as_text()).result
	file.close()
	for action in custom_configs["controls"]:
		set_specific_keybind(action,custom_configs["controls"][action][0],custom_configs["controls"][action][1])
	emit_signal("configs_updated")
func save_configs():
	var file = File.new()
	file.open(configs_file,file.WRITE)
	file.store_line(JSON.print(custom_configs))
	file.close()
func set_specific_keybind(action, keybind,keybind_type): # Sets a specific keybind
	if not InputMap.get_actions().has(action):
		InputMap.add_action(action)
	delete_specific_keybind(action)
	var key
	if keybind_type == "InputEventKey":
		key = InputEventKey.new()
		key.set_scancode(keybind)
	elif keybind_type == "InputEventMouseButton":
		key = InputEventMouseButton.new()
		key.set_button_index(keybind)
	InputMap.action_add_event(action, key)

func delete_specific_keybind(action):
	InputMap.action_erase_events(action)

func delete_save(save):
	var dir = Directory.new()
	if not dir.dir_exists(GalaxySave.SAVE_FILE_PATH):
		dir.make_dir(GalaxySave.SAVE_FILE_PATH)
	dir.open(GalaxySave.SAVE_FILE_PATH)
	var err = dir.remove(save)
	if err != OK:
		print("deletion error. code:")
		print(err)
