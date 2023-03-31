extends Node2D

func _on_Interactable_interacted_with():
	# if on planet, create planet scene, if in space, send to space scene
	if GalaxySave.game_data["storyProgression"] < 5:
		GalaxySave.game_data["storyProgression"] = 5
	GalaxySave.game_data["shipPosition"][6] = true
	GalaxySave.set_ship_speed(0)


func _on_Interactable_player_nearby():
	if GalaxySave.game_data["storyProgression"] < 5:
		SignalBus.emit_signal("display_announcement","ship_tour_chair")
