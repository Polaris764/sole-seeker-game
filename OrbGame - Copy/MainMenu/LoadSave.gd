extends "res://MainMenu/BaseMenu.gd"

onready var save_holder = preload("res://MainMenu/SaveHolder.tscn")
onready var save_container = $MarginContainer/MenuContainer/ScrollContainer/SaveHolderHolder

func _ready():
	scrollBar.modulate.a = 0
	var path = GalaxySave.SAVE_FILE_PATH
	var dir = Directory.new()
	if not dir.dir_exists(path):
		dir.make_dir(path)
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file.begins_with("save_file"):
			var button_instance = save_holder.instance()
			button_instance.assigned_save = file
			save_container.add_child(button_instance)
		elif file == "":
			break

onready var scrollBar = $MarginContainer/MenuContainer/ScrollContainer.get_v_scrollbar()
onready var STween = $Tween2
func _on_LoadSave_appearing():
	yield($Tween,"tween_all_completed")
	STween.interpolate_property(scrollBar,"modulate:a",0,1,.5,Tween.TRANS_LINEAR)
	STween.start()
func _on_LoadSave_disappearing():
	STween.interpolate_property(scrollBar,"modulate:a",1,0,.5,Tween.TRANS_LINEAR)
	STween.start()
