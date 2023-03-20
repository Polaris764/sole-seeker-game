extends Sprite

onready var animator = $AnimationPlayer
onready var timer = $expression_timer

enum expression {
	Idle,
	Disappointed,
	Happy,
	Angry,
	Ecstatic,
	Crazy1,
	Crazy2
}

var expression_to_frame = {expression.Idle:0,expression.Disappointed:1,expression.Happy:2,expression.Angry:3,expression.Ecstatic:5,expression.Crazy1:6,expression.Crazy2:7}

export (expression) var current_expression = expression.Idle setget change_expression

func change_expression(value):
	current_expression = value
	frame = expression_to_frame.get(value)

func _ready():
	_on_expression_timer_timeout()

func _on_expression_timer_timeout():
	animator.play("glitch" + str(expression_to_frame[current_expression])+ str(randi()%(vframes-1)))
	timer.start(randi()%3+3)
func expression_glitch_ended():
	frame = expression_to_frame.get(current_expression)


func _on_Interactable_interacted_with():
	ConstantsHolder.update_story_from_atos()
