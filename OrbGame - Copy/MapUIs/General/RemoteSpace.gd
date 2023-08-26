extends Node2D

onready var tScene = $TransitionScene

func _ready():
	AudioManager.play_song([AudioManager.songs.still],"deepSpace")
	tScene.emit_signal("load_complete")
	if not ConstantsHolder.leaving_map:
		tScene.queue_free()
