extends CollisionPolygon2D

export var draw_array : PoolVector2Array
export var biome_type : String
export var transparency : float = .5 setget transparency_update

func _draw():
	var color_used
	match biome_type:
		"white":
			color_used = Color(1,1,1,transparency)
		"red":
			color_used = Color(1,.015,0,transparency)
		"blue":
			color_used = Color(0,.216,1,transparency)
		"purple":
			color_used = Color(.718,0,1,transparency)
		"orange":
			color_used = Color(1,.651,0,transparency)
		"black":
			color_used = Color(.137,.137,.137,transparency)
	draw_colored_polygon(draw_array,color_used)
func transparency_update(value):
	transparency = value
	update()
