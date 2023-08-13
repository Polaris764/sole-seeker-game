extends Node2D

onready var animator = $AnimationPlayer
onready var zap_animator = $AnimatedSprite
onready var aPlayer = $capturerAudio
var target

func _ready():
	animator.playback_speed = 2

func _on_Range_body_entered(body):
	target = body
	zap_animator.visible = true
	zap_animator.play("default")
	aPlayer.play()

func destroy_self():
	var data = GalaxySave.get_planet_building_data()
	var current_building_type = ConstantsHolder.building_types.CAPTURER
	data[current_building_type].erase(global_position)
	GalaxySave.set_building_data(data)
	GalaxySave.save_data()
	queue_free()

func _on_AnimatedSprite_animation_finished():
	if target:
		var captured_enemes_list = GalaxySave.game_data["capturedEnemies"]
		captured_enemes_list.append(target.name)
		target.queue_free()
	destroy_self()

# Needs to:
# - remove orb
# - store type of orb
# - remove capturer
