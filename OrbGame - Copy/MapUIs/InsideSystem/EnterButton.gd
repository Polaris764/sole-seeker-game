extends TextureButton
export var transferring = false

func _ready():
	get_node("../..").modulate.a = 0
	var relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	$EnterLabel.text = "Enter\n" + str(relevantButtons)

func _on_EnterButton_pressed():
	if GalaxySave.game_data["shipPosition"][7] != 0:
		transferring = true
	# uses star position and position of planet to uniquely set up city pattern
		emit_signal("entering_planet")
func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact"):
		if GalaxySave.game_data["shipPosition"][7] != 0:
			transferring = true
			# uses star position and position of planet to uniquely set up city pattern
			emit_signal("entering_planet")

func update_ship_stats():
		GalaxySave.set_ship_speed(-1,true)
		GalaxySave.game_data["shipPosition"][6] = true
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation

#warning-ignore:unused_signal
signal entering_planet
signal scene_switch
func _on_EnterButton_scene_switch():
	update_ship_stats()
	var _change = get_tree().change_scene("res://OnFootAssets/VisitingPlanet.tscn")

var star
var star_pos
var bookmarkable = true
onready var bButton = get_node("../BookmarkButton/BLabel")
func _on_BookmarkButton_pressed():
	print("b button pressed")
	print(bookmarkable)
	if bookmarkable:
		bButton.text = "Unbookmark"
		GalaxySave.game_data["bookmarkedStars"][star] = star_pos
		bookmarkable = false
	else:
		bButton.text = "Bookmark"
		if GalaxySave.game_data["bookmarkedStars"].has(star):
			GalaxySave.game_data["bookmarkedStars"].erase(star)
		bookmarkable = true


func _on_EnterButton_mouse_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func _on_EnterButton_mouse_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)

func _on_BookmarkButton_mouse_entered():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor2)
func _on_BookmarkButton_mouse_exited():
	Input.set_custom_mouse_cursor(ConstantsHolder.mouseCursor1)
