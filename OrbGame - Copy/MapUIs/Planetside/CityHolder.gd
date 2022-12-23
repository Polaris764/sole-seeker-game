extends Node2D

func _on_CityButton_pressed():
	print("city pressed")
	get_tree().change_scene("res://ShipInside.tscn")
