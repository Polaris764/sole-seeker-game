extends Node2D

export(PackedScene) var BULLET: PackedScene = null

var current_target = null
var angle_to_target = null

onready var gunSprite = $Sprite
onready var reloadTimer = $Timer

func _physics_process(_delta):
	if viable_enemies.size() > 0:
		if not current_target or (!current_target.get_ref()):
			current_target = weakref(viable_enemies[0])
		if current_target:
			if current_target.get_ref().get_node("Stats").health <= 0:
				viable_enemies.remove(viable_enemies.find(current_target.get_ref()))
				current_target = null
		if viable_enemies.size() > 0:
			if not current_target:
				current_target = weakref(viable_enemies[0])
			angle_to_target = rad2deg(global_position.direction_to(current_target.get_ref().global_position).angle())+180
			#warning-ignore:integer_division
			var target_frame = int(stepify(angle_to_target,45))/45-6
			gunSprite.frame = target_frame if target_frame > -1 else target_frame + 8
			if reloadTimer.is_stopped():
				shoot()

func shoot():
	print("PEW")
	
	if BULLET:
		var bullet: Node2D = BULLET.instance()
		bullet.target = current_target.get_ref().global_position
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
	
	reloadTimer.start()

var viable_enemies = []
func _on_AttackRadius_body_entered(body):
	viable_enemies.append(body)
func _on_AttackRadius_body_exited(body):
	var left_body = viable_enemies.find(body)
	if left_body:
		viable_enemies.remove(left_body)
