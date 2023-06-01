extends Node2D

func _on_Area2D_body_entered(body):
	if body.name ==  "Player":
		custom_interaction()
		if GalaxySave.game_data["storyProgression"] < 5:
			SignalBus.emit_signal("display_announcement","ship_tour_door")

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node("../YSort/Player/InteractionButton").areaLeft(self)
	
#door destination
export var planet_scene : NodePath = "res://OnFootAssets/VisitingPlanet.tscn"
export var station_scene : NodePath = "res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn"

func custom_interaction():
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	get_node("../YSort/Player/InteractionButton").updateButton(relevantButtons,"Exit Ship",self,"Interact")

func interacted():
	var ship_location = GalaxySave.game_data["shipPosition"][7]
	if ship_location == 0:
		var _change = get_tree().change_scene(station_scene)
	else:
		var _change = get_tree().change_scene(planet_scene)
