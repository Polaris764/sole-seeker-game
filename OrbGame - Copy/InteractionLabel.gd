extends Label

export var interaction_result = "Interact" setget update_text
export var disabled_message : String setget update_text_disabled
export var control = 'Interact'

func _ready():
	update_text_disabled("")

func update_text_disabled(text_input):
	disabled_message = text_input
	if not disabled_message:
		var relevantButtons = []
		for i in InputMap.get_action_list(control):
			if i is InputEventKey:
				relevantButtons.append(i.as_text())
		text = str(relevantButtons) + " to " + interaction_result
	else:
		text = disabled_message

func update_text(text_input):
	interaction_result = text_input
	var relevantButtons = []
	for i in InputMap.get_action_list(control):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	text = str(relevantButtons) + " to " + interaction_result

signal interacted_with
func interacted():
	emit_signal("interacted_with")

func _process(delta):
	if Input.is_action_just_pressed(control) and not disabled_message:
		interacted()
