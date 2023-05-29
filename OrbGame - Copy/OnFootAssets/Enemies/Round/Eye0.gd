extends Sprite

onready var sprites = []

func _ready():
	for item in get_all_children(get_node("../..")):
		if "Eye" in item.name and item != self:
			sprites.append(item)

func _on_Eye0_frame_changed():
	for item in sprites:
		item.frame = frame

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
