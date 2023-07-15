extends "res://MainMenu/BaseMenu.gd"

onready var warning = $MarginContainer/MenuContainer/NameHolder/NameWarning
onready var warning_tween = $MarginContainer/MenuContainer/NameHolder/Tween
onready var text_loc = $MarginContainer/MenuContainer/NameHolder/TextEditor
onready var create_but = $MarginContainer/MenuContainer/CreateButton
onready var file = File.new()

func _on_TextEditor_text_changed(new_text):
	if file.file_exists(GalaxySave.SAVE_FILE_PATH + "save_file-" + new_text.replace(" ","_") + "-.save"):
		warning.rect_position.x = text_loc.rect_position.x + text_loc.rect_size.x
		warning_tween.interpolate_property(warning,"modulate:a",warning.modulate.a,1,.5)
		warning_tween.start()
		create_but.disabled = true
	elif warning.modulate.a != 0:
		warning_tween.interpolate_property(warning,"modulate:a",warning.modulate.a,0,.5*warning.modulate.a)
		warning_tween.start()
		create_but.disabled = false
