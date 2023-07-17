extends CanvasLayer

onready var player = get_node("../Player")
onready var wave_rect = $WaveEffect
onready var blur_rect = $BlurEffect
onready var tween = $Tween

func _on_Player_speed_check(above):
	if above:
		create_speed()
	else:
		lose_speed()
func create_speed():
	player.get_node("Particles2D").emitting = true
	tween.interpolate_property(wave_rect,"modulate:a",wave_rect.modulate.a,1,2)
	tween.start()
	tween.interpolate_property(blur_rect,"modulate:a",blur_rect.modulate.a,1,2)
	tween.start()
func lose_speed():
	player.get_node("Particles2D").emitting = false
	tween.interpolate_property(wave_rect,"modulate:a",wave_rect.modulate.a,0,2)
	tween.start()
	tween.interpolate_property(blur_rect,"modulate:a",blur_rect.modulate.a,0,2)
	tween.start()
