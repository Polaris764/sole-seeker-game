extends Node

var activePlaylists = {}

var rng

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func play_song(song:Array,playlistName:String,start_pos = 0):
	if not activePlaylists.has(playlistName):
		var audioplayer = AudioStreamPlayer.new()
		audioplayer.bus = "Music"
		audioplayer.pause_mode = Node.PAUSE_MODE_PROCESS
		mute_ongoing_songs()
		activePlaylists[playlistName] = audioplayer
		audioplayer.stream = song_enum_pairs[song[rng.randi()%song.size()]]
		audioplayer.connect("finished",self,"continue_playlist",[audioplayer,song])
		add_child(audioplayer)
		audioplayer.play(start_pos)

func stop_song(playlistName:String):
	if activePlaylists.has(playlistName):
		var audioplayer = activePlaylists[playlistName]
		audioplayer.queue_free()
		activePlaylists.erase(playlistName)

func continue_playlist(audioplayer,playlist):
	audioplayer.stream = song_enum_pairs[playlist[rng.randi()%playlist.size()]]
	audioplayer.play()

func mute_ongoing_songs():
	for item in activePlaylists:
		activePlaylists[item].volume_db = -85

func play_effect(effects:Array,startpos = 0,location=null,volume_mod = 0):
	var audioplayer
	if location:
		audioplayer = AudioStreamPlayer2D.new()
		audioplayer.global_position = location
		audioplayer.max_distance = 150
	else:
		audioplayer = AudioStreamPlayer.new()
	audioplayer.bus = "SoundEffects"
	audioplayer.volume_db += volume_mod
	audioplayer.stream = effect_enum_pairs[effects[rng.randi()%effects.size()]]
	add_child(audioplayer)
	audioplayer.connect("finished",self,"stop_effect",[audioplayer])
	audioplayer.play(startpos)

func stop_effect(audioplayer):
	audioplayer.queue_free()

enum songs {abound,array,bass,chant,combat,contact,delusional,drifting,dry,forest,found,home,martian,onwards,preparation,prey,rancor,red,release,rest,settled,still,storm,universe,unto,will}
var song_enum_pairs = {
	songs.abound:preload("res://Audio/AudioFiles/abound.ogg"),
	songs.array:preload("res://Audio/AudioFiles/array.ogg"),
	songs.bass:preload("res://Audio/AudioFiles/bass.ogg"),
	songs.chant:preload("res://Audio/AudioFiles/chant.ogg"),
	songs.combat:preload("res://Audio/AudioFiles/combat.ogg"),
	songs.contact:preload("res://Audio/AudioFiles/contact.ogg"),
	songs.delusional:preload("res://Audio/AudioFiles/delusional.ogg"),
	songs.drifting:preload("res://Audio/AudioFiles/drifting.ogg"),
	songs.dry:preload("res://Audio/AudioFiles/dry.ogg"),
	songs.forest:preload("res://Audio/AudioFiles/forest.ogg"),
	songs.found:preload("res://Audio/AudioFiles/found.ogg"),
	songs.home:preload("res://Audio/AudioFiles/home.ogg"),
	songs.martian:preload("res://Audio/AudioFiles/martian.ogg"),
	songs.onwards:preload("res://Audio/AudioFiles/onwards.ogg"),
	songs.preparation:preload("res://Audio/AudioFiles/preparation.ogg"),
	songs.prey:preload("res://Audio/AudioFiles/prey.ogg"),
	songs.rancor:preload("res://Audio/AudioFiles/rancor.ogg"),
	songs.red:preload("res://Audio/AudioFiles/red.ogg"),
	songs.release:preload("res://Audio/AudioFiles/release.ogg"),
	songs.rest:preload("res://Audio/AudioFiles/rest.ogg"),
	songs.settled:preload("res://Audio/AudioFiles/settled.ogg"),
	songs.still:preload("res://Audio/AudioFiles/still.ogg"),
	songs.storm:preload("res://Audio/AudioFiles/storm.ogg"),
	songs.universe:preload("res://Audio/AudioFiles/universe.ogg"),
	songs.unto:preload("res://Audio/AudioFiles/unto.ogg"),
	songs.will:preload("res://Audio/AudioFiles/will.ogg")
}

enum effects {breakage,cannon,landing,healMachine,laserZap,menuClick,mine,needle,net,pauseClick,placement1,placement2,placement3,rain,respawn,shipLift,supersonic,turret,unfurl}
var effect_enum_pairs = {
	effects.breakage:preload("res://Audio/SoundEffects/break.ogg"),
	effects.cannon:preload("res://Audio/SoundEffects/cannon.ogg"),
	effects.landing:preload("res://Audio/SoundEffects/landing.ogg"),
	effects.healMachine:preload("res://Audio/SoundEffects/healMachine.wav"),
	effects.laserZap:preload("res://Audio/SoundEffects/laserZap.wav"),
	effects.menuClick:preload("res://Audio/SoundEffects/menuClick.wav"),
	effects.mine:preload("res://Audio/SoundEffects/mine.wav"),
	effects.needle:preload("res://Audio/SoundEffects/needle.wav"),
	effects.net:preload("res://Audio/SoundEffects/net.wav"),
	effects.pauseClick:preload("res://Audio/SoundEffects/pauseClick.wav"),
	effects.placement1:preload("res://Audio/SoundEffects/placement1.wav"),
	effects.placement2:preload("res://Audio/SoundEffects/placement2.wav"),
	effects.placement3:preload("res://Audio/SoundEffects/placement3.wav"),
	effects.respawn:preload("res://Audio/SoundEffects/respawn.wav"),
	effects.shipLift:preload("res://Audio/SoundEffects/shipLift.wav"),
	effects.supersonic:preload("res://Audio/SoundEffects/supersonic.wav"),
	effects.turret:preload("res://Audio/SoundEffects/turret.wav"),
	effects.unfurl:preload("res://Audio/SoundEffects/unfurl.wav")
}
