extends Camera2D
var spd = 80

func _process(delta):

	if Input.is_action_just_released("zoom_in"):
		if self.zoom.x - .1 > .5:
			self.zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_released("zoom_out"):
		if self.zoom.x + .1 < 35:
			self.zoom += Vector2(0.1, 0.1)
		
	var width = get_viewport().size.x
	var height = get_viewport().size.y
	var radius_required_to_move = min(width,height)/4
	var mouse_position = get_global_mouse_position()
	var mouse_delta = mouse_position - global_position
	if (mouse_delta.length() >= radius_required_to_move):
		position += (mouse_delta / radius_required_to_move) * spd * delta
