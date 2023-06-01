extends Node2D

onready var signalBus = SignalBus
onready var player = $YSort/Player
onready var respawner = $YSort/Respawner
onready var zap = respawner.get_node("ZapSprite")

func _ready():
	var storyPos = GalaxySave.game_data["storyProgression"]
	if storyPos < 5:
		start_tour()
	elif storyPos == 7:
		signalBus.emit_signal("display_announcement","ship_guide2")
		GalaxySave.game_data["storyProgression"] = 8
	elif storyPos == 8:
		if GalaxySave.game_data["backpackBlood"]["red"] > 0:
			signalBus.emit_signal("display_announcement","ship_guide3")
			GalaxySave.game_data["storyProgression"] = 9
		else:
			signalBus.emit_signal("display_announcement","ship_guide2.5")
	elif storyPos == 10:
		signalBus.emit_signal("display_announcement","ship_guide5")
		GalaxySave.game_data["storyProgression"] = 11
	if ConstantsHolder.respawning:
		respawn_player()

func start_tour():
	signalBus.emit_signal("display_announcement","ship_tour1")

func respawn_player():
	player.set_positions_of_animation_trees(Vector2(0,1))
	ConstantsHolder.respawning = false
	player.add_collision_exception_with(respawner.get_node("StaticBody2D"))
	player.global_position = respawner.global_position + Vector2(0,-1)
	zap.visible = true
	zap.play("default")
