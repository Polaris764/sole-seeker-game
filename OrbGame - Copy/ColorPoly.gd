extends CollisionPolygon2D
var mewarray

func _draw():
	draw_colored_polygon(PoolVector2Array(mewarray[0]),Color(.251,.769,.137,.6))
