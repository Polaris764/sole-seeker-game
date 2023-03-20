extends Sprite

onready var timer = $Timer
onready var animator = $AnimationPlayer

func _on_Interactable_interacted_with():
	ConstantsHolder.update_story_from_atos()

func _ready():
	_on_Timer_timeout()

func _on_Timer_timeout():
	animator.play("glitch" + str((randi()%(hframes-1))+1))
	timer.start(randi()%3+3)
