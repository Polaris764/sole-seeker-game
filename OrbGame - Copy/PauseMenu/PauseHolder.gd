extends CanvasLayer

onready var pause_inventory = $PauseInventory
onready var travel_logs = $PauseTravel
onready var enemy_handbook = $PauseHandbook

var current_scene = null
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not current_scene:
			var menus = [pause_inventory,travel_logs,enemy_handbook]
			for item in menus:
				item.initialize()
			change_scene(pause_inventory)
		else:
			change_scene()

func change_scene(new_scene = null):
	if new_scene:
		if current_scene: # normal menu scene change
			current_scene.hide()
		else: # pause menu first activated
			get_tree().paused = true
		current_scene = new_scene
		current_scene.show()
	elif current_scene: # pause menu being hidden
		current_scene.hide()
		current_scene = null
		get_tree().paused = false
