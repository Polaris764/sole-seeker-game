extends Sprite

var sprites = []
var spritesRight = []
var spritesLeft = []
onready var BaseL = $BaseL
onready var BaseR = $BaseR

func _ready():
	var children = get_children()
	children.erase(BaseL)
	children.erase(BaseR)
	for item in children:
		if item is Sprite:
			sprites.append(item)
	for sprite in sprites:
		var spriteL = sprite.get_node("BaseL")
		spritesLeft.append(spriteL)
		var spriteR = sprite.get_node("BaseR")
		spritesRight.append(spriteR)

func _on_Body0_frame_changed():
	for item in sprites:
		item.frame = frame

func _on_BaseL_frame_changed():
	for item in spritesLeft:
		item.frame = BaseL.frame

func _on_BaseR_frame_changed():
	for item in spritesRight:
		item.frame = BaseR.frame
