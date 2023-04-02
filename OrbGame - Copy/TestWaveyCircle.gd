extends Node2D

var star = preload("res://MapUIs/GalaxyMap/PlanetarySystem.tscn")
export var point_count = 100
export var circle_radius = 2000
export var variance_radius = 500
export var cosine_length = 12
export var cosine_length2 = 12
export var sin_length = 3
func _ready():
	make_circle()
func make_circle():
	for child in $Node2D.get_children():
		child.queue_free()
	var collision = CollisionPolygon2D.new()
	var ptArray = PoolVector2Array()
	$Node2D.add_child(collision)
	for point in point_count:
		var circle_radius2 = circle_radius + variance_radius*cos(cosine_length*PI*point/point_count)*sin(sin_length*PI*point/point_count)*cos(cosine_length2*PI*point/point_count)# + 100*cos(2*PI*point/100)
		var newCon = star.instance()
		$Node2D.add_child(newCon)
		var point_angle = (2*PI)/point_count*point
		newCon.global_position = Vector2(2*cos(point_angle),sin(point_angle))*Vector2(circle_radius2,circle_radius2)
		ptArray.append(Vector2(2*cos(point_angle),sin(point_angle))*Vector2(circle_radius2,circle_radius2))
	collision.polygon = ptArray

func _on_Timer_timeout():
	make_circle()
