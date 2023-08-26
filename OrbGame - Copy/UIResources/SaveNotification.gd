extends CanvasLayer

onready var tween = $Tween

func _on_SaveNotification_ready():
	tween.interpolate_property($Label,"modulate:a",0,1,1)
	tween.start()

var appeared = false
func _on_Tween_tween_completed(_object, _key):
	if not appeared:
		appeared = true
		tween.interpolate_property($Label,"modulate:a",1,0,1)
		tween.start()
	else:
		queue_free()
