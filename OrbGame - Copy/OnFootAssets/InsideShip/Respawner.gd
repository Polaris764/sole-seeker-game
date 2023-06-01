extends Node2D

onready var backupCam = get_node("../../BackupCam")
onready var player = get_node("../Player")

func _on_Interactable_interacted_with(): # for healing
	backupCam.global_position = player.global_position
	backupCam.current = true

func _on_Interactable_player_nearby():
	if GalaxySave.game_data["storyProgression"] < 5:
		SignalBus.emit_signal("display_announcement","ship_tour_respawner")

func _on_PlatformArea_body_exited(body):
	if body == player:
		player.remove_collision_exception_with($StaticBody2D)

var plays = 0
func _on_ZapSprite_animation_finished():
	plays += 1
	if plays >= 4:
		$ZapSprite.stop()
		$ZapSprite.visible = false
		player.remove_cutscene("death")
