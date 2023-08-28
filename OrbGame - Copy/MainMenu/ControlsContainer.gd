extends Container

var previous_pos = 0
var previous_height = 0
export var separation = 15

func _ready():
	position_children()

func position_children():
	previous_height = 0
	previous_pos = 0
	for item in get_children():
#		print(item.name + str(item.rect_position))
#		print(str(previous_pos) + " " + str(previous_height) + " " + str(separation))
		item.rect_position.y = previous_pos+previous_height
		if item.get_index() != 0:
			item.rect_position.y += separation
		previous_pos = item.rect_position.y
		previous_height = item.rect_size.y
	rect_min_size = Vector2(984,previous_pos + previous_height + separation)

func add_child(node, _choice = false):
	.add_child(node)
	node.rect_size.x = 984
	position_children()


func button_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func button_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
