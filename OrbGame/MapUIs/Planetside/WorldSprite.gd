extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var screenSizeX = get_viewport_rect().size.x
	var screenSizeY = get_viewport_rect().size.y
	get_node("..").scale.x = screenSizeX/1280
	get_node("..").scale.y = 1.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
