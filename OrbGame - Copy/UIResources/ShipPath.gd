extends Path2D

var inc=0
var speed=100

export var duration = 5
onready var path = $PathFollow2D
onready var tween = $ShipTween
onready var ship = $PathFollow2D/Sprite
onready var JEffect = $PathFollow2D/Sprite/SpeedParticles
var largeSize = Vector2(1.5,1.5)
var smallSize = Vector2(.2,.2)
onready var direction = get_parent().direction
func _ready():
	if direction:
		speed = 300
		JEffect.emitting = true
		tween.interpolate_property(ship,"scale",smallSize,largeSize,duration,Tween.TRANS_LINEAR)
	else:
		speed = 225
		JEffect.emitting = false
		tween.interpolate_property(ship,"scale",largeSize,smallSize,duration,Tween.TRANS_LINEAR)
	tween.start()
	$Timer.start(duration/2-.7)

func _process(delta):
	inc+=delta*speed
	path.offset=inc

func _on_Timer_timeout():
	yield(get_tree().create_timer(.7), "timeout")
	if direction:
		speed = 150
		JEffect.emitting = false
	else:
		JEffect.emitting = true
		speed = 400
	$Timer2.start(duration/2)
