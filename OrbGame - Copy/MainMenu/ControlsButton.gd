extends "res://MainMenu/UIButtonBase.gd"

export var assigned_action : String setget set_button_text

var selected = false
var customizable_controls = ConstantsHolder.customizable_controls
onready var cooldownTimer = get_node("../../CooldownTimer")
onready var settingsMenu = get_node("../../../../..")

func start_cooldown():
	settingsMenu.on_cooldown = true
	cooldownTimer.start(.25)

func set_button_text(action):
	if action != "":
		assigned_action = action
		var controls_list = []
		for i in InputMap.get_action_list(action):
			if i is InputEventKey:
				controls_list.append(i.as_text())
			elif i is InputEventMouseButton:
				controls_list.append("Mouse Button " + str(i.button_index))
			else:
				print("not valid button for controls text")
		text = customizable_controls[action] + " = " + str(controls_list)
		selected = false

func _on_ControlsButton_pressed():
	if not settingsMenu.on_cooldown:
		selected = true
		text = customizable_controls[assigned_action] + " = press any key" 

onready var UIHolder = get_node("../../../../../..")
func _input(event):
	if event is InputEventKey and selected or event is InputEventMouseButton and selected:
		var keybind
		if "scancode" in event:
			keybind = event.get_scancode()
		else:
			keybind = event.get_button_index()
		set_specific_keybind(assigned_action,keybind,event.get_class())
		selected = false
		start_cooldown()

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
	else:
		print("invalid button type")
		print(keybind_type)
	InputMap.action_add_event(action, key)
	UIHolder.custom_configs["controls"][action] = [keybind,keybind_type]
	UIHolder.save_configs()
	set_button_text(assigned_action)

func delete_specific_keybind(action):
	InputMap.action_erase_events(action)

func _ready():
	UIHolder.connect("configs_updated",self,"set_button_text",[assigned_action])
