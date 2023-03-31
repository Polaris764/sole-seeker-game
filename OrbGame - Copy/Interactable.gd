extends Node2D

export var player_node : NodePath

export var required_story_pos = 0

signal player_nearby
func _on_Area2D_body_entered(body):
	if body.name ==  "Player":
		emit_signal("player_nearby")
		if GalaxySave.game_data["storyProgression"] >= required_story_pos:
			custom_interaction()


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node(player_node).get_node("InteractionButton").areaLeft(self)


export var interaction_result := "Activate"
func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	get_node(player_node).get_node("InteractionButton").updateButton(relevantButtons,interaction_result,self,"Interact")

signal interacted_with
func interacted():
	emit_signal("interacted_with")
