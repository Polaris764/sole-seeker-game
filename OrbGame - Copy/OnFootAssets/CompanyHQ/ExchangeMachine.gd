extends Node2D
export var player_node : NodePath
func _on_Interactable_interacted_with():
	var storyPos = GalaxySave.game_data["storyProgression"]
	if storyPos == 11:
		GalaxySave.game_data["storyProgression"] = 12
	var player = get_node(player_node)
	var player_menu = player.get_node("UI/ShopMenu")
	get_tree().paused = true
	player_menu.visible = true


onready var sprite = $Interactable/Sprite
onready var timer = $Timer
var rng = RandomNumberGenerator.new()
func _on_Timer_timeout():
	if sprite.frame == 0:
		sprite.frame = 1
		timer.start(rng.randf_range(.5,1.5))
	else:
		sprite.frame = 0
		timer.start(rng.randf_range(7,15))
