extends Node2D
export var CompanyStation = true

func growSprite(spriteName):
	spriteName.set_scale(Vector2(2,2))
func shrinkSprite(spriteName):
	$SizeTween.interpolate_property(spriteName, "scale", Vector2(2,2), Vector2(1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SizeTween.start()
	


func _on_Area2D_body_entered(body):
	var playerStarList = get_parent().starsInside
	var i = playerStarList.find(self)
	if i < 0:
		playerStarList.insert(0,self)
		get_parent().starsInside = playerStarList
		growSprite(self)
		updateSystemInfoPanel() # set HQ info
		if playerStarList.size() == 1:
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



func _on_Area2D_body_exited(body):
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
		updateSystemInfoPanel2(playerStarList[0].global_position)
		growSprite(playerStarList[0])
	if self.get_scale().x > 1:
		shrinkSprite(self)

var stationIm = preload("res://MapUIs/GalaxyMap/companyHQ.png")
var starIm = preload("res://MapUIs/InsideSystem/closeupStar.png")

func updateSystemInfoPanel():
	var pStarImage = get_node("../SystemInfo/Control/Holder/StarImage")
	var pStarName = get_node("../SystemInfo/Control/Holder/StarName")
	var pStarCoords = get_node("../SystemInfo/Control/Holder/StarCoords")
	var pPlanetAmount = get_node("../SystemInfo/Control/Holder/PlanetAmount")
	var pSystemType = get_node("../SystemInfo/Control/Holder/SystemType")
	
	pStarImage.texture = starIm
	pStarImage.texture = stationIm # set station image
	pStarImage.rect_size = Vector2(64,64)
	pStarImage.modulate = Color.white # return to default color
	pStarName.text = "Company Headquarters"
	var degPos = rad2deg(atan2(self.global_position.y,self.global_position.x))*-1
	if degPos < 0:
		degPos += 360
	pStarCoords.text = String(self.global_position.distance_to(Vector2(0,0))) + ", " + String(degPos)+"°" #set star coordinates
	pPlanetAmount.text = "Planet Count: N/A" #set planet amount
	pSystemType.text = "System Type: Orb Reciever" #generate system type
	
var planetAmountOptions = [0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,10,11,12,13,14]
onready var constantsHolder = get_node("/root/ConstantsHolder")
func updateSystemInfoPanel2(seedUsed):
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
	pSystemType.text = "System Type: " + systemTypeOptions[randi() % systemTypeOptions.size()] #generate system type
