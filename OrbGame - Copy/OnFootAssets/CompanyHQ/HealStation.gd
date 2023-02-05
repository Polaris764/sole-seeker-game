extends Node2D
onready var player = get_node("../Player")
func _on_Interactable_interacted_with():
	PlayerStats.health = PlayerStats.max_health
