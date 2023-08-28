extends CanvasLayer

onready var tween = $Tween
onready var rng = RandomNumberGenerator.new()

export var transition_duration : float = 1

signal appearing
signal disappearing

var screen_edge = 1004

func disappear():
	emit_signal("disappearing")
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
	var targets = get_tree().get_nodes_in_group("TransitionTarget")
	for item in targets:
#		if "disabled" in item:
#			item.disabled = true
		tween.interpolate_property(item,"rect_position:x",item.rect_position.x,-screen_edge,transition_duration,Tween.TRANS_CUBIC,Tween.EASE_IN,rng.randf_range(0,.5))
		tween.start()
	yield(tween,"tween_all_completed")
	hide()

func appear():
	emit_signal("appearing")
	var targets = get_tree().get_nodes_in_group("TransitionTarget")
	for item in targets:
#		if "disabled" in item:
#			item.disabled = false
		item.rect_position.x = screen_edge
		var target_position = 0
		if "desired_position" in item:
			target_position = item.desired_position
		tween.interpolate_property(item,"rect_position:x",screen_edge,target_position,transition_duration,Tween.TRANS_CUBIC,Tween.EASE_OUT,rng.randf_range(0,.5))
		tween.start()
	show()
