extends "res://OnFootAssets/Hitboxes-Hurtboxes/Hitbox.gd"

export var speed = 30
export var target : Vector2
var velocity = null

func _ready():
	if target:
		look_at(target)

func _physics_process(delta):
	if not velocity:
		velocity = global_position.direction_to(global_position.move_toward(target,delta))
	global_position += velocity*speed

func _on_VisibilityNotifier2D_screen_exited():
	print("done1")
	queue_free()

func _on_Bullet_body_entered(body):
	print("done2")
	queue_free()
