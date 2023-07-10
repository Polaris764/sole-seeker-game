extends "res://MainMenu/BaseMenu.gd"

onready var mapping_holder = $MarginContainer/MenuContainer/ScrollContainer/ControlsContainer
onready var button_base = preload("res://MainMenu/UIButtonBase.tscn")

func _ready():
	scrollBar.modulate.a = 0
	build_control_list()

var customizable_controls = {"move_forward":"Move Up","move_left":"Move Left","move_backward":"Move Down","move_right":"Move Right","Interact":"Interact","attack":"Attack","harvest":"Harvest","build_state_switch":"Switch State","inventory":"Inventory","increase_speed":"Increase Speed","decrease_speed":"Decrease Speed","weapon_switch_up":"Weapon Switch Up","weapon_switch_down":"Weapon Switch Down"}
func build_control_list():
	for item in get_tree().get_nodes_in_group("InputLabels"):
		item.queue_free()
	
	for action in customizable_controls:
		var actionButton = button_base.instance()
		actionButton.add_to_group("TransitionTarget")
		actionButton.add_to_group("InputLabels")
		var controls_list = []
		for i in InputMap.get_action_list(action):
			if i is InputEventKey:
				controls_list.append(i.as_text())
		actionButton.text = customizable_controls[action] + " = " + str(controls_list)
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
