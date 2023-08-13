extends Node2D

func _ready():
	AudioManager.play_song([AudioManager.songs.still],"deepSpace")
