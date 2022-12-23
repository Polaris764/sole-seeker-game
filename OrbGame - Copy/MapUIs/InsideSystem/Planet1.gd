extends TextureButton


var rotation_around_point = 0
var distance_from_point = 100

func _process(delta):
	var star = get_node("../../Star")
	var rotation_point = star.get_global_transform()
	# set the position to the point
	var global_position = rotation_point
	# offset using the rotation
	global_position *= Vector2(cos(rotation_around_point), sin(rotation_around_point)) * distance_from_point
