extends Container


var children_organized
func organize_children():
	children_organized = 0
	for item in get_children():
		if children_organized % 3 == 2:
			item.rect_position.x = 328*2
		elif children_organized % 3 == 1:
			item.rect_position.x = 328
		item.rect_position.y = 328 * int(children_organized/3)
		item.desired_position = item.rect_position.x
		rect_min_size = Vector2(0,item.rect_position.y+item.rect_size.y)
		children_organized += 1

func _ready():
	organize_children()

func add_child(node, _setting = true):
	.add_child(node)
	organize_children()
