extends Node2D
onready var player = get_node("../Player")
onready var timer = $HealTimer
export var heal_duration = 6
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Interactable/Sprite
onready var back_sprite = $Interactable/Back
onready var heal_pos = $Position2D
onready var exit_pos = $Position2D2
var process_starting = false
onready var backup_cam = get_node("../../BackupCamera")
onready var audioPlayer = $HealAudio
var has_healed = false
func _ready():
	if GalaxySave.game_data["storyProgression"] == 0:
		sprite.frame = 0
	else:
		sprite.frame = 4
	

func _on_Interactable_interacted_with():
	healing()

func healing():
	process_starting = true
	timer.start(heal_duration)
	player.add_cutscene(name)
	backup_cam.global_position = player.global_position
	backup_cam.current = true
	player.global_position = heal_pos.global_position
	if GalaxySave.game_data["storyProgression"] != 0 or has_healed:
		animationPlayer.play_backwards("DoorsOpen")
	player.z_index = 1
	sprite.z_index = 2
	audioPlayer.play()

func _on_HealTimer_timeout():
	process_starting = false
	animationPlayer.play("DoorsOpen")
	PlayerStats.health = PlayerStats.max_health
	audioPlayer.stop()
	has_healed = true

func on_animation_end():
	if not process_starting:
		player.z_index = 0
		sprite.z_index = 0
		player.remove_cutscene(name)
		player.global_position = backup_cam.global_position
		player.get_node("Camera2D").current = true
		GalaxySave.save_data()
#	back_sprite.z_index = 0

