extends Node2D

onready var backupCam = get_node("../../BackupCam")
onready var player = get_node("../Player")

func _on_Interactable_interacted_with(): # for healing
	backupCam.global_position = player.global_position
	backupCam.current = true

func _on_Interactable_player_nearby():
	if GalaxySave.game_data["storyProgression"] < 5:
		SignalBus.emit_signal("display_announcement","ship_tour_respawner")
