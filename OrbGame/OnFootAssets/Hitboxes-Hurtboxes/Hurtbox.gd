extends Area2D

const HitEffect = preload("res://OnFootAssets/Effects/HitEffect.tscn")

var invincible = false setget set_invincible
onready var timer = $Timer

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	var size_rangeX = $CollisionShape2D.shape.radius/2 if $CollisionShape2D.shape.radius else $CollisionShape2D.shape.extents.x/2
	var size_rangeY = $CollisionShape2D.shape.radius/2 if $CollisionShape2D.shape.radius else $CollisionShape2D.shape.extents.y/2
	effect.global_position = $CollisionShape2D.global_position + Vector2(rand_range(-size_rangeX,size_rangeX),rand_range(-size_rangeY,size_rangeY))


func _on_Timer_timeout():
	self.invincible = false


func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring",false)


func _on_Hurtbox_invincibility_ended():
	monitoring = true
