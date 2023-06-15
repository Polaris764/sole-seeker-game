extends Node2D

onready var animator = $AnimationPlayer
var playing_forwards = true
func _on_AnimationPlayer_animation_finished(anim_name):
	if playing_forwards:
		playing_forwards = false
		animator.play_backwards(anim_name)
	else:
		playing_forwards = true
		animator.play(anim_name)
