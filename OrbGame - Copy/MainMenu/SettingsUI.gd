extends "res://MainMenu/BaseMenu.gd"

onready var mapping_holder = $MarginContainer/MenuContainer/ScrollContainer/ControlsContainer
onready var button_base = preload("res://MainMenu/ControlsButton.tscn")

var on_cooldown = false

func _ready():
	scrollBar.modulate.a = 0
	build_control_list()

var customizable_controls = ConstantsHolder.customizable_controls
func build_control_list():
	for item in get_tree().get_nodes_in_group("InputLabels"):
		item.queue_free()
	
	for action in customizable_controls:
		var actionButton = button_base.instance()
		actionButton.add_to_group("TransitionTarget")
		actionButton.add_to_group("InputLabels")
		actionButton.assigned_action = action
		mapping_holder.add_child(actionButton)

onready var scrollBar = $MarginContainer/MenuContainer/ScrollContainer.get_v_scrollbar()
onready var STween = $ScrollTween
func _on_SettingsUI_disappearing():
	STween.interpolate_property(scrollBar,"modulate:a",1,0,.5,Tween.TRANS_LINEAR)
	STween.start()
func _on_SettingsUI_appearing():
	yield($Tween,"tween_all_completed")
	STween.interpolate_property(scrollBar,"modulate:a",0,1,.5,Tween.TRANS_LINEAR)
	STween.start()

onready var uiHolder = get_node("..")
func _on_DefaultControls_pressed():
	uiHolder.custom_configs["controls"] = uiHolder.custom_configs["default_controls"]
	for item in uiHolder.custom_configs["default_controls"]:
		set_specific_keybind(item, uiHolder.custom_configs["default_controls"][item][0], uiHolder.custom_configs["default_controls"][item][1])
	uiHolder.save_configs()
	uiHolder.emit_signal("configs_updated")

func set_specific_keybind(action, keybind, keybind_type): # Sets a specific keybind
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
	uiHolder.custom_configs["controls"][action] = [keybind,keybind_type]
	uiHolder.save_configs()

func delete_specific_keybind(action):
	InputMap.action_erase_events(action)

func _on_BackButton_pressed():
	uiHolder.emit_signal("configs_updated")

func _on_CooldownTimer_timeout():
	on_cooldown = false
