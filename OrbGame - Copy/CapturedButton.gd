extends TextureButton

export var organism_type : String
export var organism_icon : String

signal capture_button_clicked

func _ready():
	var texture = load(organism_icon)
	texture_normal = texture

func _on_CapturedButton_pressed():
	emit_signal("capture_button_clicked",self)

func _on_CapturedButton_mouse_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func _on_CapturedButton_mouse_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
