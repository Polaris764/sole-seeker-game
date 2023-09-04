extends CanvasLayer

export (String, FILE, "*json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false

export var announcement_duration = 5

onready var background = $Background
onready var text_label = $Background/TextLabel
onready var timer = $Timer

func _ready():
	visible = true
	background.visible = false
	scene_text = load_scene_text()
	var _connection = SignalBus.connect("display_announcement", self, "on_display_announcement")

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
	
func on_display_announcement(text_key):
	AudioManager.play_effect([AudioManager.effects.announcement])
	timer.start(announcement_duration)
#	if in_progress:
#		pass
#		#next_line()
#	else:
	background.visible = true
	in_progress = true
	selected_text = scene_text[text_key].duplicate()
	show_text()


func _on_Timer_timeout():
	finish()
