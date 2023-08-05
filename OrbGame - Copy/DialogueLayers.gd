extends CanvasLayer

export (String, FILE, "*json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false

var pause_while_showing = true

onready var background = $Background
onready var text_label = $Background/Label

func _ready():
	background.visible = false
	scene_text = load_scene_text()
	var _signal_connection = SignalBus.connect("display_dialogue", self, "on_display_dialog")

func load_scene_text():
	var file = File.new()
	if file.file_exists(scene_text_file):
		file.open(scene_text_file, File.READ)
		return parse_json(file.get_as_text())

func show_text():
	text_label.text = selected_text.pop_front()

func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():
	text_label.text = ""
	background.visible = false
	in_progress = false
	if pause_while_showing:
		get_tree().paused = false
	
func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		if pause_while_showing:
			get_tree().paused = true
		background.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
