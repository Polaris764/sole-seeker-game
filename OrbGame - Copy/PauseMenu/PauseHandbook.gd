extends "res://PauseMenu/PauseBase.gd"

onready var oButtonHolder = $VBoxContainer/GridContainer
onready var descHolder = $VBoxContainer/DescriptionContainer
onready var oImage = $VBoxContainer/DescriptionContainer/ImageHolder/TextureRect
onready var oDesc = $VBoxContainer/DescriptionContainer/oDesc
onready var oStr = $VBoxContainer/DescriptionContainer/Strengths
onready var oWea = $VBoxContainer/DescriptionContainer/Weaknesses
onready var notif = $VBoxContainer/Research

var organism_descriptions = {"BlueOrb":"A small and fast organism that lives alone. It loses interest quickly due to the high energy necessary to extend a chase.","RedOrb":"A wide-reaching organism that stays in packs. They are capable of surviving on their own but truly thrive when with others.","PurpleEnemy":"A territorial burrowing creature. Only one lives on a planet at a time, but its enormous tentacles are able to reach the entire area at maturity. Severed limbs begin to grow a new creature.","OrangeEnemy":"A pustular growth that builds colonies over time. The organism repopulates by releasing spores occasionally, making up for its lack of movement.","BrownEnemy":"The spawn of a pustular growth that is willing to sacrifice its life for the colony. Their sole role in existence is security. They are only produced when the colony is in danger to conserve resources.","Round":"A rare behemoth creature that dominates the planets it resides on. Generally relies on feeling terrain for daily functioning but will use eyesight while on the hunt. The body contains valuable materials as it is the top of the food chain."}
var organism_strengths = {"BlueOrb":"Speed, Small Size","RedOrb":"Health, Allies","PurpleEnemy":"Surprise","OrangeEnemy":"Allies","BrownEnemy":"Damage, Allies","Round":"Health, Damage"}
var organism_weaknesses = {"BlueOrb":"Control, Damage","RedOrb":"Speed","PurpleEnemy":"Agility","OrangeEnemy":"Movement","BrownEnemy":"Lifetime","Round":"Size"}
var blue = "res://OnFootAssets/UI/CapturedComponents/BlueThumbnail.png"
var red = "res://OnFootAssets/UI/CapturedComponents/RedThumbnail.png"
var purple = "res://OnFootAssets/UI/CapturedComponents/PurpleThumbnail.png"
var orange = "res://OnFootAssets/UI/CapturedComponents/OrangeThumbnail.png"
var brown = "res://OnFootAssets/UI/CapturedComponents/BrownThumbnail.png"
var roundo = "res://OnFootAssets/UI/CapturedComponents/RoundThumbnail.png"
var organism_images = {"BlueOrb":blue,"RedOrb":red,"PurpleEnemy":purple,"OrangeEnemy":orange,"BrownEnemy":brown,"Round":roundo}
func _ready():
	for i in oButtonHolder.get_children():
		i.connect("pressed",self,"oButtonPressed",[i.name])

func oButtonPressed(buttonName):
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	oImage.texture = load(organism_images[buttonName])
	oDesc.text = organism_descriptions[buttonName]
	oStr.text = "Strengths: " + organism_strengths[buttonName]
	oWea.text = "Weaknesses: " + organism_weaknesses[buttonName]
	
	oButtonHolder.hide()
	descHolder.show()
	notif.hide()

func _on_ReturnButton_pressed():
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	oButtonHolder.show()
	descHolder.hide()
	notif.show()
