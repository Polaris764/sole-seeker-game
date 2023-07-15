extends Button

enum DROPOFF {left,right}
export(DROPOFF) var alignment = DROPOFF.right setget align_self
var selected_texture = preload("res://MainMenu/SelectedBox.png")
var unselected_texture = preload("res://MainMenu/UnselectedBox.png")
export var Checkbox_Text : String = ""
export var desired_position = 0

export var selected = false

func _ready():
	align_self(alignment)
			
func align_self(position):
	alignment = position
	$BoxTitle.text = Checkbox_Text
	match alignment:
		DROPOFF.right:
			$BoxTitle.rect_position.x = 20
			$Box.rect_position.x = 440
			$BoxTitle.align = Label.ALIGN_RIGHT
		DROPOFF.left:
			$Box.rect_position.x = 20
			$BoxTitle.rect_position.x = 63
			$BoxTitle.align = Label.ALIGN_LEFT
func _on_CustomCheckbox_pressed():
	selected = not selected
	if selected:
		$Box.texture = selected_texture
	else:
		$Box.texture = unselected_texture
