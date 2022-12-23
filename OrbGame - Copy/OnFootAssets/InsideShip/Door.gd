extends Node2D

func _on_Area2D_body_entered(body):
	if body.name ==  "Player":
		custom_interaction()

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node("../InteractionButton").areaLeft(self)
	
#door destination
export var scene : NodePath = "res://OnFootAssets/VisitingPlanet.tscn"
func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	get_node("../InteractionButton").updateButton(relevantButtons,"Exit Ship",self,"Interact")

func interacted():
	get_tree().change_scene(scene)
