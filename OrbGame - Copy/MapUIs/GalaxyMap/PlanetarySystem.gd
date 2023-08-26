extends Node2D
export var CompanyStation = false
onready var texButton = $TextureButton

func _on_TextureButton_pressed():
	#GalaxySave.setLastStarClicked(self.global_position.x)
	print(system_type_dup)
	#get_tree().change_scene("res://MapUIs/InsideSystem/InsideSystem.tscn")
	
func growSprite(spriteName):
	spriteName.set_scale(Vector2(2,2))
func shrinkSprite(spriteName):
	$SizeTween.interpolate_property(spriteName, "rect_scale", Vector2(2,2), Vector2(1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SizeTween.call_deferred("start")

func _on_Area2D_body_entered(_body):
	var playerStarList = get_parent().starsInside
	var i = playerStarList.find(self)
	if i < 0:
		playerStarList.append(self)
		get_parent().starsInside = playerStarList
		if playerStarList.size() == 1:
			growSprite(texButton)
			updateSystemInfoPanel(playerStarList[0].global_position) # set star info
			$Tween.stop_all()
			$Tween.interpolate_property(
				get_node("../SystemInfo/Control"),
				'modulate:a',
				get_node("../SystemInfo/Control").get_modulate().a,
				1,
				0.25,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			) # show info panel
			$Tween.call_deferred("start")

func _on_Area2D_body_exited(_body):
	var playerStarList = get_parent().starsInside
	var i = playerStarList.find(self)
	if i > -1:
		playerStarList.remove(i)
		get_parent().starsInside = playerStarList
	if playerStarList.size() == 0:
		$Tween.stop_all()
		$Tween.interpolate_property(
			get_node("../SystemInfo/Control"),
			'modulate:a',
			get_node("../SystemInfo/Control").get_modulate().a,
			0.0,
			0.25,
			Tween.TRANS_SINE,
			Tween.EASE_OUT
		) # hide info panel
		$Tween.call_deferred("start")
	elif i == 0:
		#print("updating")
		updateSystemInfoPanel(playerStarList[0].global_position)
		growSprite(playerStarList[0].get_node("TextureButton"))
	if texButton.get_scale().x > 1:
		shrinkSprite(texButton)


onready var constantsHolder = get_node("/root/ConstantsHolder")
var starIm = preload("res://MapUIs/InsideSystem/closeupStar.png")
func updateSystemInfoPanel(seedUsed):
	var starNameOptions = constantsHolder.starNameOptions
	var pStarImage = get_node("../SystemInfo/Control/Holder/StarImage")
	var pStarName = get_node("../SystemInfo/Control/Holder/StarName")
	var pStarCoords = get_node("../SystemInfo/Control/Holder/StarCoords")
	var pPlanetAmount = get_node("../SystemInfo/Control/Holder/PlanetAmount")
	var pSystemType = get_node("../SystemInfo/Control/Holder/SystemType")
	
	var keyedSeed = pow(seedUsed.x,2)*cos(pow(seedUsed.x,3))
	seed(keyedSeed)
	var planetAmount
	if GalaxySave.game_data["gameModifications"]["megasystems"]:
		planetAmount = ConstantsHolder.megaPlanetAmountOptions[randi() % ConstantsHolder.megaPlanetAmountOptions.size()]
	else:
		planetAmount = ConstantsHolder.planetAmountOptions[randi() % ConstantsHolder.planetAmountOptions.size()]

	pStarImage.texture = starIm
	pStarImage.rect_size = Vector2(64,64)
	pStarImage.modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1) #set star texture
	pStarName.text = starNameOptions[randi() % starNameOptions.size()].capitalize() #generate star name
	var degPos = rad2deg(atan2(seedUsed.y,seedUsed.x))*-1
	if degPos < 0:
		degPos += 360
	pStarCoords.text = String(seedUsed.distance_to(Vector2(0,0))) + ", " + String(degPos)+"°" #set star coordinates
	pPlanetAmount.text = "Planet Count: " + String(planetAmount) #set planet amount
	pSystemType.text = get_system_type()
	

onready var enterButtonText = get_node("../SystemInfo/Control/Holder/EnterButton/EnterLabel")
func set_enter_button_text(accessible):
	if accessible:
		var relevantButtons = []
		for i in InputMap.get_action_list('Interact'):
			if i is InputEventKey:
				relevantButtons.append(i.as_text())
		enterButtonText.text = "Enter\n" + str(relevantButtons)
	else:
		enterButtonText.text = "Access Restricted"

export var system_type : Array setget uniquify
var system_type_dup
func uniquify(val):
	system_type_dup = val.duplicate()

func get_system_type():
	var system_type_text : String = "System Type: Error"
	#print("SYSTEM TYPE: " + get_node("../SystemInfo/Control/Holder/StarName").text)
	#print(system_type_dup)
	if system_type_dup.size() > 0:
		system_type_text = "System Type: " + array_join(system_type_dup)
	else:
		system_type_text = "System Type: Uninhabited"
	if not constantsHolder.white_system_check(system_type):
		set_enter_button_text(false)
	elif not "red" in system_type_text and GalaxySave.game_data["storyProgression"] < 11:
		set_enter_button_text(false)
	else:
		set_enter_button_text(true)
	return system_type_text

func array_join(arr, separator = ", "):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output
