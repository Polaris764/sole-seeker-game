extends Node2D

func _on_Area2D_body_entered(body):
	body.entity_trapped(1,.5)
