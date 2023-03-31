extends Area2D

export var target_story_position : int

export var required_story_position : int

export var dialogue_key = "entered_training_room"

func _on_StoryProgressor_body_entered(body):
	if GalaxySave.game_data["storyProgression"] == required_story_position:
		GalaxySave.game_data["storyProgression"] = target_story_position
		SignalBus.emit_signal("updated_story")
		SignalBus.emit_signal("display_announcement",dialogue_key)
