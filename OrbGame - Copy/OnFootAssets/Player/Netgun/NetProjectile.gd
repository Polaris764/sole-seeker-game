extends Area2D

export var speed = 100
export var steer_force = 15000

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

var live = true

func start(_transform, _target):
	global_transform = _transform
	rotation += rand_range(-0.09, 0.09)
	velocity = transform.x * speed
	target = _target

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta

func _on_NetProjectile_body_entered(body):
	if body == target and live: # target reached
		live = false
		body.entity_trapped(10)
		explode()

func _on_Lifetime_timeout():
	live = false
	explode()

func explode():
	set_physics_process(false)
	$NetSprite.visible = true
	$ProjectileSprite.visible = false
	#queue_free()