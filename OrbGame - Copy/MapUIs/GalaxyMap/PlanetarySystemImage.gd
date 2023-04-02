extends Node2D
export var CompanyStation = false
export var system_type = []


func _on_TextureButton_pressed():
	#GalaxySave.setLastStarClicked(self.global_position.x)
	get_tree().change_scene("res://MapUIs/InsideSystem/InsideSystem.tscn")
	
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
			growSprite(self)
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
		growSprite(playerStarList[0])
	if self.get_scale().x > 1:
		shrinkSprite(self)


var planetAmountOptions = [0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,10,11,12,13,14]
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
	var planetAmount = planetAmountOptions[randi() % planetAmountOptions.size()]
	
	pStarImage.texture = starIm
	pStarImage.rect_size = Vector2(64,64)
	pStarImage.modulate = Color.from_hsv((randi() % 12) / 12.0, 1, 1) #set star texture
	pStarName.text = starNameOptions[randi() % starNameOptions.size()].capitalize() #generate star name
	var degPos = rad2deg(atan2(seedUsed.y,seedUsed.x))*-1
	if degPos < 0:
		degPos += 360
	pStarCoords.text = String(seedUsed.distance_to(Vector2(0,0))) + ", " + String(degPos)+"°" #set star coordinates
	pPlanetAmount.text = "Planet Count: " + String(planetAmount) #set planet amount
	get_system_type(pSystemType)

func get_system_type(textNode):
	var system_type_desc : String
	if system_type.size() > 0:
		system_type_desc = system_type[0]
		for type in range(1,system_type.size()):
			system_type_desc += (", " + system_type[type])
		textNode.text = "System Type: " + system_type_desc
	else:
		textNode.text = "System Type: Uninhabited"
