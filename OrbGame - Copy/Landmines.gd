extends Node2D

var base_damage = 4

export var mines = 1 setget update_sprite

func update_sprite(mine_count):
	mines = mine_count
	if mines > 0 and mines < 4:
		$Sprite.frame = mine_count-1
		$Hitbox.damage = base_damage*mine_count
	else:
		destroy_self()
		print("mine removed")

func _on_Area2D_body_entered(_body):
	yield(get_tree().create_timer(.2), "timeout")
	$Hitbox/CollisionShape2D.set_deferred("disabled",false)
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("Explosion")
	$Sprite.visible = false

func _on_AnimatedSprite_animation_finished():
	destroy_self()

func destroy_self():
	var data = GalaxySave.get_planet_building_data()
	var current_building_type = ConstantsHolder.building_types.LANDMINE
	data[current_building_type].erase(global_position)
	GalaxySave.set_building_data(data)
	GalaxySave.save_data()
	print("saved destruction")
	queue_free()
