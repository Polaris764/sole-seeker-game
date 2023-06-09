extends Node2D

onready var animator = $AnimationPlayer
onready var aniTimer = $AnimationTimer

var retrieved = false
var animation_choice = 0

func _ready():
	randomize()
	aniTimer.start(rand_range(4,15))

func play_random():
	if not retrieved:
		retrieved = true
		animation_choice = randi()%3+1
		animator.play_backwards("Retrieve"+str(animation_choice))
	else:
		retrieved = false
		animator.play("Retrieve"+str(animation_choice))
	aniTimer.start(rand_range(5,16))

func _on_AnimationTimer_timeout():
	play_random()

export var player_node : NodePath
func _on_Interactable_interacted_with():
	var player = get_node(player_node)
	var player_menu = player.get_node("UI/CapturedMenu")
	get_tree().paused = true
	player_menu.visible = true
