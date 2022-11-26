extends Camera2D
var spd = 80

func _process(_delta):

	if Input.is_action_just_released("zoom_in"):
		if self.zoom.x - .1 > .5:
			self.zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_released("zoom_out"):
		if self.zoom.x + .1 < get_node("..").get_child_count()*.8: # max zoom out range, based on number of planets
			self.zoom += Vector2(0.1, 0.1)
