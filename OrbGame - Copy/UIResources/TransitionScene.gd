extends CanvasLayer

#warning-ignore:unused_signal
signal load_complete

onready var tween = $Tween
export var direction = true

func _on_TransitionScene_load_complete():
	self.req2 = true

onready var ship = $ShipPath/PathFollow2D
onready var tween2 = $ShTween
onready var sh = $Shockwave
onready var sh2 = $Shockwave


func _on_Timer_timeout():
	tween2.interpolate_property(sh.material,"shader_param/size",0,2,1.5,Tween.TRANS_QUART,Tween.EASE_OUT)
	tween2.start()

	sh2.rect_position = ship.global_position
	tween2.interpolate_property(sh2.material,"shader_param/size",0,2,1.5,Tween.TRANS_QUART,Tween.EASE_IN)
	tween2.start()

var req1 = false setget end_load1
var req2 = false setget end_load2

func end_load1(cond):
	req1 = cond
	if req1 and req2:
		end_load()
func end_load2(cond):
	req2 = cond
	if req1 and req2:
		end_load()
func end_load():
	tween.interpolate_property($Colors,"modulate:a",1,0,1)
	tween.interpolate_property($ShipPath,"modulate:a",1,0,1)
	tween.start()

func _on_Tween_tween_completed(_object, _key):
	queue_free()


func _on_Timer2_timeout():
	self.req1 = true
