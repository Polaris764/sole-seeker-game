extends Node2D

onready var polygonA = $CollisionPolygon2D
onready var polygonB = $CollisionPolygon2D2
var mewarray
func _ready():
	mewarray = (Geometry.merge_polygons_2d(polygonA.polygon, polygonB.polygon))
	print(mewarray)
	print(PoolVector2Array(mewarray[0]))
	polygonB.queue_free()
	polygonA.mewarray = mewarray
	polygonA.update()
