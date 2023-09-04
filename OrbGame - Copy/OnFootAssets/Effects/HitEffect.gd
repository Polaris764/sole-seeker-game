extends Node2D

func _ready():
	var _connection = $Sprite0.connect("animation_finished",self,"_on_animation_finished")
	for i in get_children():
		i.play("default")

func _on_animation_finished():
	queue_free()
