extends TextureRect

func _process(delta):
	var rotation_speed = 6.5
	self.rect_rotation += delta*rotation_speed
