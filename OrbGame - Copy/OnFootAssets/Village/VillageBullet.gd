extends Area2D
export var speed = 30
export var velocity := Vector2() setget calibrate_velocity
export var player : NodePath setget calibrate_player
var playerNode
export var homing_target : NodePath setget get_node_target
var tNode
var homing = true

func calibrate_player(value):
	player = value
	playerNode = get_node("../" + player)
func get_node_target(target):
	homing_target = target
	tNode = get_node("../" + target).global_position
	look_at(tNode)

func calibrate_velocity(set_amount):
	rotation = set_amount.x
	velocity = Vector2(cos(set_amount.x),sin(set_amount.x))

func _physics_process(delta):
	if tNode:
		if homing:
			velocity = global_position.direction_to(tNode+playerNode.input_velocity*24)
		global_position += velocity*speed*delta
	else:
		position = position + velocity * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_VillageBullet_body_entered(body):
	#player hit
	create_hit_effect()
	body.health = -1
	if tNode:
		pass # tracking
	queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	homing = false


func _on_VillageBullet_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	#entered house
	queue_free()

const HitEffect = preload("res://OnFootAssets/Effects/HitEffect.tscn")
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	var size_rangeX = $CollisionShape2D.shape.radius/2 if $CollisionShape2D.shape.radius else $CollisionShape2D.shape.extents.x/2
	var size_rangeY = $CollisionShape2D.shape.radius/2 if $CollisionShape2D.shape.radius else $CollisionShape2D.shape.extents.y/2
	effect.global_position = $CollisionShape2D.global_position + Vector2(rand_range(-size_rangeX,size_rangeX),rand_range(-size_rangeY,size_rangeY))
