extends StaticBody2D

export var active = true setget activity_set
export var alignment_HV = true setget alignment_set
var initialized = false

func activity_set(status):
	active = status
	set_items_to_alignment_and_status()
	var building_info = GalaxySave.get_planet_building_data()
	if status:
		$Hitbox/CollisionShape2D.set_deferred("disabled",false)
		if not initialized:
			initialized = true
		else:
			building_info[ConstantsHolder.building_types.LASER][global_position][1] = true
	else:
		$Hitbox/CollisionShape2D.set_deferred("disabled",true)
		if not initialized:
			initialized = true
		else:
			building_info[ConstantsHolder.building_types.LASER][global_position][1] = false
	GalaxySave.set_building_data(building_info)
	GalaxySave.save_data()

func alignment_set(alignment_set_to):
	alignment_HV = alignment_set_to
	set_items_to_alignment_and_status()

func set_items_to_alignment_and_status():
	if alignment_HV: #horizontal
		$Sprite.offset = Vector2(-24,-39)
		$Hitbox.position = Vector2(0,-16)
		$Hitbox/CollisionShape2D.position = Vector2(8,9)
		$Hitbox/CollisionShape2D.rotation = 0
		$Detector.position = Vector2(0,-16)
		$Detector/CollisionShape2D.position = Vector2(8,9)
		$Detector/CollisionShape2D.rotation = 0
		
		$LeftHorizontal.set_deferred("disabled",false)
		$RightHorizontal.set_deferred("disabled",false)
		$LeftVertical.set_deferred("disabled",true)
		$RightVertical.set_deferred("disabled",true)
		if active:
			$Sprite.frame = 0
		else:
			$Sprite.frame = 1
	else:
		$Sprite.offset = Vector2(-24,-21)
		$Hitbox.position = Vector2(0,2)
		
		$Hitbox/CollisionShape2D.position = Vector2(8,7)
		$Hitbox/CollisionShape2D.rotation = PI/2
		$Detector.position = Vector2(0,2)
		$Detector/CollisionShape2D.position = Vector2(8,7)
		$Detector/CollisionShape2D.rotation = PI/2
		$LeftHorizontal.set_deferred("disabled",true)
		$RightHorizontal.set_deferred("disabled",true)
		$LeftVertical.set_deferred("disabled",false)
		$RightVertical.set_deferred("disabled",false)
		if active:
			$Sprite.frame = 2
		else:
			$Sprite.frame = 3

func _on_Hitbox_damage_dealt():
	AudioManager.play_effect([AudioManager.effects.laserZap],0,global_position)
	self.active = false

func laser_repaired():
	self.active = true

var disabled_for_player_passthrough = false setget set_sprite_color

func set_sprite_color(value):
	disabled_for_player_passthrough = value
	if value: #player in laser
		$Sprite.use_parent_material = false
		$Hitbox/CollisionShape2D.set_deferred("disabled",true)
	else: #player left laser
		$Sprite.use_parent_material = true
		$Hitbox/CollisionShape2D.set_deferred("disabled",false)

func _on_Detector_area_entered(area):
	if area.is_in_group("PlayerHurtbox") and active:
		self.disabled_for_player_passthrough = true

func _on_Detector_area_exited(area):
	if area.is_in_group("PlayerHurtbox") and disabled_for_player_passthrough:
		self.disabled_for_player_passthrough = false
