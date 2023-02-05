extends Node2D

func _on_Area2D_body_entered(body):
	if body.name ==  "Player":
		custom_interaction()


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node("../../Player/InteractionButton").areaLeft(self)


export var interaction_result := "Activate"
func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	get_node("../../Player/InteractionButton").updateButton(relevantButtons,interaction_result,self,"Interact")

signal interacted_with
func interacted():
	emit_signal("interacted_with")
