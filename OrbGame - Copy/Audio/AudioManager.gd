extends Node

enum songs {array,bass,forest,rancor,home,release,storm}
var song_enum_pairs = {
	songs.array:preload("res://Audio/AudioFiles/array.ogg"),
	songs.bass:preload("res://Audio/AudioFiles/bass.ogg"),
	songs.forest:preload("res://Audio/AudioFiles/forest.ogg"),
	songs.rancor:preload("res://Audio/AudioFiles/rancor.ogg"),
	songs.home:preload("res://Audio/AudioFiles/home.ogg"),
	songs.release:preload("res://Audio/AudioFiles/release.ogg"),
	songs.storm:preload("res://Audio/AudioFiles/storm.ogg")
}

enum effects {}
var effect_enum_pairs = {}

var song_dictionary = {}
func play_song(song,start_pos = 0):
	if not song_dictionary.has(song):
		var audioplayer = AudioStreamPlayer.new()
		audioplayer.bus = "Music"
		audioplayer.stream = song_enum_pairs[song]
		add_child(audioplayer)
		audioplayer.play(start_pos)
		song_dictionary[song] = audioplayer

func stop_song(song):
	if song_dictionary.has(song):
		var audioplayer = song_dictionary[song]
		audioplayer.queue_free()
		song_dictionary.erase(song)


func play_effect(effect):
	var audioplayer = AudioStreamPlayer.new()
	audioplayer.bus = "SoundEffects"
	audioplayer.stream = effect_enum_pairs[effect]
	add_child(audioplayer)
	audioplayer.connect("finished",self,"stop_effect",[audioplayer])
	audioplayer.play()

func stop_effect(audioplayer):
	audioplayer.queue_free()
