extends Sprite

var active = true

export var alignment_HV = true setget alignment_set

func alignment_set(alignment_set_to):
	alignment_HV = alignment_set_to
	set_items_to_alignment_and_status()

func set_items_to_alignment_and_status():
	if alignment_HV: #horizontal
		offset = Vector2(8,-7)
		if active:
			frame = 0
		else:
			frame = 1
	else:
		offset = Vector2(8,11)
		if active:
			frame = 2
		else:
			frame = 3
