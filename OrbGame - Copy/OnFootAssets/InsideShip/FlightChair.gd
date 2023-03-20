extends Node2D

func _on_Interactable_interacted_with():
	# if on planet, create planet scene, if in space, send to space scene
	GalaxySave.game_data["shipPosition"][6] = true
	GalaxySave.set_ship_speed(0)
