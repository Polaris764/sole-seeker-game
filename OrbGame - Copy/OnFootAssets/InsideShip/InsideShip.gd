extends Node2D

onready var signalBus = SignalBus
onready var player = $YSort/Player
onready var respawner = $YSort/Respawner
onready var zap = respawner.get_node("ZapSprite")
onready var cover = $TransitionCover/ColorRect
onready var tween = $TransitionCover/Tween

func _ready():
	var storyPos = GalaxySave.game_data["storyProgression"]
	respawner.get_node("Interactable").required_story_pos = 999
	if storyPos < 5:
		respawner.get_node("Interactable").required_story_pos = 0
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
	else:
		if ConstantsHolder.leaving_map:
			player.global_position = $YSort/FlightChair.global_position
		else:
			player.global_position = $Door.global_position
			cover.modulate.a = 1
			tween.interpolate_property(cover,"modulate:a",1,0,.5)
			tween.start()
	ConstantsHolder.leaving_map = true

func start_tour():
	signalBus.emit_signal("display_announcement","ship_tour1")

func respawn_player():
	player.set_positions_of_animation_trees(Vector2(0,1))
	ConstantsHolder.respawning = false
	player.add_collision_exception_with(respawner.get_node("StaticBody2D"))
	player.global_position = respawner.global_position + Vector2(0,-1)
	zap.visible = true
	zap.play("default")
