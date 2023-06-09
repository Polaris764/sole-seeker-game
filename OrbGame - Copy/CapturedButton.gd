extends TextureButton

export var organism_type : String
export var organism_icon : String

signal capture_button_clicked

func _ready():
	var texture = load(organism_icon)
	texture_normal = texture

func _on_CapturedButton_pressed():
	emit_signal("capture_button_clicked",self)
