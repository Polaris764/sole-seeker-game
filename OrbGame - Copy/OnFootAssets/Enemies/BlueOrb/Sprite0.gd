extends Sprite

var sprites = []
func _ready():
	for item in get_children():
		if item is Sprite:
			sprites.append(item)
func _on_Sprite0_frame_changed():
	for item in sprites:
		item.frame = frame
