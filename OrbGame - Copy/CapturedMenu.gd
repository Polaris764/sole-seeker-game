extends Control

onready var captured_grid = $TextureRect/ScrollContainer/GridContainer
onready var button_scene = preload("res://OnFootAssets/UI/CapturedComponents/CapturedButton.tscn")
onready var organism_menu = $OrganismMenu
onready var close_button = $TextureRect/CloseButton
onready var blur = $TextureRect/BlurCover
onready var terminated_label = $TextureRect/TerminatedLabel
onready var tween = $TextureRect/TerminatedLabel/Tween
onready var term_button = $OrganismMenu/TerminateButton
onready var contact_button = $OrganismMenu/ContactButton
onready var name_to_file = ConstantsHolder.name_to_file

func _ready():
	organism_menu.visible = false
	calibrate_inventory()

func _on_CloseButton_pressed():
	close_self()

func close_self():
	visible = false
	get_tree().paused = false

func calibrate_inventory():
	clear_buttons()
	var inventory = GalaxySave.game_data["capturedEnemies"]
	for item in inventory:
		var button = button_scene.instance()
		var itemName = ""
		var itemIcon = ""
		match item:
			"BlueOrb":
				itemName = "Blue"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/BlueThumbnail.png"
			"BrownEnemy":
				itemName = "Brown"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/BrownThumbnail.png"
			"OrangeEnemy":
				itemName = "Orange"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/OrangeThumbnail.png"
			"PurpleEnemy":
				itemName = "Green"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/PurpleThumbnail.png"
			"RedOrb":
				itemName = "Red"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/RedThumbnail.png"
			"Round":
				itemName = "Purple"
				itemIcon = "res://OnFootAssets/UI/CapturedComponents/RoundThumbnail.png"
		button.organism_type = itemName
		button.organism_icon = itemIcon
		captured_grid.add_child(button)
		button.connect("capture_button_clicked",self,"button_clicked")

func clear_buttons():
	var buttons = get_tree().get_nodes_in_group("captureButtons")
	for button in buttons:
		button.queue_free()

var clicked_type
func button_clicked(origin_node):
	clicked_type = origin_node.organism_type
	organism_menu.get_node("NameLabel").text = clicked_type
	organism_menu.get_node("InfoLabel").text = ConstantsHolder.organism_descriptions[clicked_type]
	var amount_of_type_captured = 0
	var organism_file_name = name_to_file[clicked_type]
	for organism in GalaxySave.game_data["capturedEnemies"]:
		if organism == organism_file_name:
			amount_of_type_captured += 1
	organism_menu.get_node("CurrentCapLabel").text = "Current of organism captured: " + str(amount_of_type_captured)
	organism_menu.get_node("TotalKillLabel").text = "Total of organism killed: " + str(GalaxySave.game_data["individualKills"][clicked_type.to_lower()])
	var texture = load(origin_node.organism_icon)
	organism_menu.get_node("EnemyView").texture = texture
	organism_menu.visible = true
	close_button.visible = false
#	blur.visible = true

# rows of captured enemies in scrolling menu
# clickable to show blurb about enemy
# clicking also gives option to terminate, which gives orb resources and ?bonus?
# capturers are end game items for after player is able to kill round boss without instakilling capturer

func _on_CloseButton2_pressed():
	close_info_box()

func _on_TerminateButton_pressed():
	if clicked_type:
		GalaxySave.game_data["capturedEnemies"].erase(name_to_file[clicked_type])
		GalaxySave.game_data["storedBlood"][clicked_type.to_lower()] += 1
		calibrate_inventory()
		close_info_box()
		terminated_label.modulate = Color(1,1,1,1)
		tween.interpolate_property(terminated_label,"modulate",Color(1,1,1,1), Color(1,1,1,0), 3)
		tween.start()
		GalaxySave.save_data()
		
func close_info_box():
	organism_menu.visible = false
	close_button.visible = false

func _on_ContactButton_pressed():
	ConstantsHolder.contact_organism = name_to_file[clicked_type]
	calibrate_inventory()
	close_info_box()
	close_self()
	var _change = get_tree().change_scene("res://OnFootAssets/CompanyHQ/ContactArena.tscn")
	# arena or something fun and unique, potentially new gameplay aspect
