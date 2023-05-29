extends Control

export var active = false
export var target_pos = Vector2(0,0)
onready var cam = get_node("../../Camera2D")
onready var sprite = $Arrow

func _process(_delta):
	if active:
		var center = cam.get_camera_screen_center()
		var vec = target_pos - center
		var half_size = (get_viewport_rect().size / 2)
		var nearest_edge = get_closest_edge_point(half_size,vec.angle())
		if vec.length() < nearest_edge*.33: #.2 for exact point
			hide()
		else:
			show()
		sprite.set_rotation(vec.angle())
		sprite.set_global_position(half_size + Vector2(cos(vec.angle()),sin(vec.angle())).normalized() * nearest_edge *.8)

func get_closest_edge_point(middle,angle):
	var size = get_viewport().size
	var x1 = 0
	var x2 = size.x
	var y1 = size.y
	var y2 = 0
	var px = middle.x
	var py = middle.y
	var vx = cos(angle)
	var vy = sin(angle)
	var intersects = [(x1-px)/vx,(x2-px)/vx,(y1-py)/vy,(y2-py)/vy]
	var edited_intersects = []
	for location in intersects:
		if location > 0:
			edited_intersects.append(location)
	return edited_intersects.min()
