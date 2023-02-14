extends StaticBody2D

export var active = true setget activity_set

func activity_set(status):
	active = status
	if status:
		$Sprite.frame = 0
		$Hitbox/CollisionShape2D.set_deferred("disabled",false)
	else:
		$Sprite.frame = 1
		$Hitbox/CollisionShape2D.set_deferred("disabled",false)

func _on_Hitbox_damage_dealt():
	self.active = false

func laser_repaired():
	self.active = true
