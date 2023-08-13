extends Area2D

export var speed = 100
export var steer_force = 15000

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null
var slowness_power = .02

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
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta

func _on_NetProjectile_body_entered(body):
	if body == target and live: # target reached
		live = false
		body.entity_trapped(10,slowness_power)
		explode()

func _on_Lifetime_timeout():
	live = false
	explode()

var exploded = false
func explode():
	if not exploded:
		exploded = true
		AudioManager.play_effect([AudioManager.effects.unfurl],0,global_position)
		set_physics_process(false)
		$NetSprite.visible = true
		$ProjectileSprite.visible = false
		#queue_free()
