extends Node2D
onready var player = get_node("../Player")
onready var timer = $HealTimer
export var heal_duration = 6

func _on_Interactable_interacted_with():
	healing()

func healing():
	timer.start(heal_duration)
	player.add_cutscene(name)
	player.global_position = $Interactable.global_position

func _on_HealTimer_timeout():
	PlayerStats.health = PlayerStats.max_health
	player.remove_cutscene(name)
