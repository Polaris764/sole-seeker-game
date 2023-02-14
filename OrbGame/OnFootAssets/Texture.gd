extends TextureRect

func _ready():
	var img = get_node("../../PlanetWorld").get_viewport().get_texture().get_data()
	img.flip_y()
	img.save_png("res://OnFootAssets/minimap.png")
	self.texture = load("res://OnFootAssets/minimap.png")
