extends AnimatedSprite

func _ready():
	

func _on_animation_finished():
	get_parent().queue_free()
