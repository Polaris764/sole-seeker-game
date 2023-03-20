extends Area2D

export var dialogue_key = ""
var area_active = false

func _input(event):
	if area_active and event.is_action_pressed("Interact"):
		SignalBus.emit_signal("display_dialogue",dialogue_key)

func _on_DialogueArea_area_entered(area):
	area_active = true

func _on_DialogueArea_area_exited(area):
	area_active = false
