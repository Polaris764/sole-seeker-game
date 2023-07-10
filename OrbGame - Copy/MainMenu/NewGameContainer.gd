extends Container

var previous_size = 0
var previous_position = 0
export var separation = 15

func _ready():
	arrange_children()

func arrange_children():
	for item in get_children():
		item.rect_size.x = rect_size.x/2
		var y_pos
		if item.get_index() < 2:
			y_pos = 0
		else:
			y_pos = previous_position + previous_size + separation
		if item.get_index()%2 == 0:
			item.rect_position = Vector2(0,y_pos)
			if item.get_index() == get_child_count() - 1:
				previous_position = item.rect_position.y
				previous_size = item.rect_size.y
		else:
			item.rect_position = Vector2(rect_size.x/2,y_pos)
			previous_position = item.rect_position.y
			previous_size = item.rect_size.y
			if "alignment" in item:
				item.alignment = item.DROPOFF.left
			if "desired_position" in item:
				item.desired_position = rect_size.x/2
	rect_size.y = previous_position + previous_size

func add_child(node, _choice = false):
	.add_child(node)
	node.rect_size.x = 984
	arrange_children()
