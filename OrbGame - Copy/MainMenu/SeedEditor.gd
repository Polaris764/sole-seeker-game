extends LineEdit

onready var LineEditRegEx = RegEx.new()
var old_text = ""

func _ready() -> void:
	if get_parent().name == "SeedHolder":
		LineEditRegEx.compile("[0-9]")
	elif get_parent().name == "NameHolder":
		LineEditRegEx.compile("[A-Za-z0-9 ]")

func _on_SeedEditor_text_changed(new_text):
	var valid = true
	if not new_text == "":
		for character in new_text:
			if not LineEditRegEx.search(character): 
				valid = false
				break
	if valid:
		old_text = str(new_text)
	else:
		text = old_text
		set_cursor_position(text.length())
