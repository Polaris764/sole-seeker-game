extends TextureButton

onready var storyPos = GalaxySave.game_data["storyProgression"]
onready var starNameLabel = get_node("../StarName")
var relevantButtons
onready var enter_label = $EnterLabel
func _ready():
	set_button_text_enter()

func set_button_text_enter():
	relevantButtons = []
	for i in InputMap.get_action_list('Interact'):
		if i is InputEventKey:
			relevantButtons.append(i.as_text())
	enter_label.text = "Enter\n" + str(relevantButtons)

func _on_EnterButton_pressed():
	enter_system()

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact"):
		enter_system()

func enter_system():
	if get_node("../../../..").starsInside.size() > 0 and get_node("../../../../Player").functional:
			var currentStar = get_node("../../../..").starsInside[0]
			GalaxySave.setLastStarClicked(currentStar.global_position,starNameLabel.text,currentStar.system_type)
			if currentStar.CompanyStation == true:
				update_ship_stats(true)
				if get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn") != OK:
					print("error changing to CompanyHQ inside scene.")## transport to company scene
			elif not "Access Restricted" in enter_label.text:
				if ConstantsHolder.white_system_check(currentStar.system_type):
					update_ship_stats(false)
					GalaxySave.game_data["starsVisitedArray"].append(starNameLabel.text)
					GalaxySave.game_data["starsVisitedDictionary"][starNameLabel.text] = currentStar.global_position
					if get_tree().change_scene("res://MapUIs/InsideSystem/SystemMap.tscn") != OK:
						print("error changing to system map scene.")
func update_ship_stats(companyStation):
	if companyStation:
		GalaxySave.set_ship_speed(-2,true)
		GalaxySave.game_data["shipPosition"][6] = true
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation
	else:
		GalaxySave.set_ship_speed(-1,true)
		GalaxySave.game_data["shipPosition"][3] = get_node("../../../../Player").rotation
