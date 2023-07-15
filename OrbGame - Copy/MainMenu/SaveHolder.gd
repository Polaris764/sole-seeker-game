extends VBoxContainer

export var assigned_save : String setget setup_button
onready var tween = $Tween
onready var infobutton = $MoreInfoButton
onready var info1 = $SaveSeed
onready var info2 = $SaveMods
export var desired_position = 0

func setup_button(save):
	var info1x = $SaveSeed
	var info2x = $SaveMods
	assigned_save = save
	$InputTitle.text = save.split("-")[-2].replace("_"," ")
	if "save_file_default" in save:
		$InputTitle.text = "Game " + $InputTitle.text
	var file = File.new()
	file.open(GalaxySave.SAVE_FILE_PATH + save,File.READ)
	var game_data = file.get_var()
	file.close()
	info1x.text = "Game seed: " + str(game_data["galaxySeed"])
	var mods = "Game Modifications:"
	var hasMods = false
	for modOption in game_data["gameModifications"]:
		if game_data["gameModifications"][modOption] == true:
			hasMods = true
			mods += "\n"
			match modOption:
				"megasystems":
					mods += "Megasystems"
				"glassCannon":
					mods += "Glass Cannon"
				"speedDemon":
					mods += "Speed Demon"
				"populationBoom":
					mods += "Population Boom"
				"agingGalaxy":
					mods += "Aging Galaxy"
				"fuelEfficient":
					mods += "Fuel Efficient"
	info2x.text = mods
	if not hasMods:
		info2x.text += "\nNone"
var info_visible = false
onready var timer = $MoreInfoButton/Timer
var on_cooldown = false
func _on_MoreInfoButton_pressed():
	if not on_cooldown:
		on_cooldown = true
		timer.start(.5)
		if info_visible:
			infobutton.text = "Show More Info"
			tween.interpolate_property(info1,"modulate:a",info1.modulate.a,0,.25,Tween.TRANS_LINEAR)
			tween.start()
			tween.interpolate_property(info2,"modulate:a",info2.modulate.a,0,.25,Tween.TRANS_LINEAR,Tween.EASE_IN,.25)
			tween.start()
			tween.interpolate_property(info1,"rect_position:y",info1.rect_position.y,infobutton.rect_position.y,.25,Tween.TRANS_LINEAR)
			tween.start()
			tween.interpolate_property(info2,"rect_position:y",info2.rect_position.y,infobutton.rect_position.y,.25,Tween.TRANS_LINEAR,Tween.EASE_IN,.25)
			tween.start()
			info_visible = false
		else:
			infobutton.text = "Hide More Info"
			tween.interpolate_property(info1,"modulate:a",info1.modulate.a,1,.25,Tween.TRANS_LINEAR,Tween.EASE_IN,.25) # delay not applying
			tween.start()
			tween.interpolate_property(info2,"modulate:a",info2.modulate.a,1,.25,Tween.TRANS_LINEAR)
			tween.start()
			tween.interpolate_property(info1,"rect_position:y",infobutton.rect_position.y,81,.25,Tween.TRANS_LINEAR,Tween.EASE_IN,.25)
			tween.start()
			tween.interpolate_property(info2,"rect_position:y",infobutton.rect_position.y,108,.25,Tween.TRANS_LINEAR)
			tween.start()
			info_visible = true
func _on_Timer_timeout():
	on_cooldown = false

func _on_LoadButton_pressed():
	var mainUI = get_node("../../../../../..")
	mainUI.start_game(assigned_save)
