extends Node2D
export var CompanyStation = false
export var system_type = [] #setget get_system_type


func _on_TextureButton_pressed():
	#GalaxySave.setLastStarClicked(self.global_position.x)
	print(system_type)
#	get_tree().change_scene("res://MapUIs/InsideSystem/InsideSystem.tscn")

func growSprite(spriteName):
	spriteName.set_scale(Vector2(2,2))
func shrinkSprite(spriteName):
	$SizeTween.interpolate_property(spriteName, "scale", Vector2(2,2), Vector2(1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SizeTween.start()

func _on_Area2D_body_entered(_body):
	var playerStarList = get_parent().starsInside
	var i = playerStarList.find(self)
	if i < 0:
		playerStarList.append(self)
		get_parent().starsInside = playerStarList
		if playerStarList.size() == 1:
			growSprite($TextureButton)
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
			$Tween.start()

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
		$Tween.start()
	elif i == 0:
		updateSystemInfoPanel(playerStarList[0].global_position)
		growSprite(playerStarList[0].get_node("TextureButton"))
	if self.get_scale().x > 1:
		shrinkSprite($TextureButton)


onready var constantsHolder = get_node("/root/ConstantsHolder")
var starIm = preload("res://MapUIs/InsideSystem/closeupStar.png")
func updateSystemInfoPanel(seedUsed):
	var starNameOptions = constantsHolder.starNameOptions
	var pStarImage = get_node("../SystemInfo/Control/Holder/StarImage")
	var pStarName = get_node("../SystemInfo/Control/Holder/StarName")
	var pStarCoords = get_node("../SystemInfo/Control/Holder/StarCoords")
	var pPlanetAmount = get_node("../SystemInfo/Control/Holder/PlanetAmount")
	var pSystemType = get_node("../SystemInfo/Control/Holder/SystemType")
	var systemTypeOptions = ["Green","Red","Green/Red"]

	var keyedSeed = pow(seedUsed.x,2)*cos(pow(seedUsed.x,3))
	seed(keyedSeed)
	var planetAmount
	if GalaxySave.game_data["gameModifications"]["megasystems"]:
		planetAmount = ConstantsHolder.megaPlanetAmountOptions[randi() % ConstantsHolder.megaPlanetAmountOptions.size()]
	else:
		planetAmount = ConstantsHolder.planetAmountOptions[randi() % ConstantsHolder.planetAmountOptions.size()]
	star_name = starNameOptions[randi() % starNameOptions.size()].capitalize()
	pStarImage.texture = starIm
	pStarImage.rect_size = Vector2(64,64)
	#pStarImage.modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1) #set star texture
	pStarName.text = star_name #generate star name
	var degPos = rad2deg(atan2(seedUsed.y,seedUsed.x))*-1
	if degPos < 0:
		degPos += 360
	pStarCoords.text = String(seedUsed.distance_to(Vector2(0,0))) + ", " + String(degPos)+"°" #set star coordinates
	pPlanetAmount.text = "Planet Count: " + String(planetAmount) #set planet amount
	pSystemType.text = str(system_type)

var star_name
var system_type_text : String = "System Type: Uninhabited"
func get_system_type(system_table):
	system_type = system_table
	if system_type.size() > 0:
		system_type_text = "System Type: Blue"
	else:
		system_type_text = "System Type: Uninhabited"
	print(star_name)
