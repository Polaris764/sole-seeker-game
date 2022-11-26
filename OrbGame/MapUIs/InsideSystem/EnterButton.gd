extends TextureButton

func _ready():
	get_node("../..").modulate.a = 0

func _on_EnterButton_pressed():
	var childArray = get_node("..").get_children()
	GalaxySave.setLastPlanetClicked(GalaxySave.getLastStarClicked(),childArray.find(self,0))
	# uses star position and position of planet to uniquely set up city pattern
	get_tree().change_scene("res://MapUIs/Planetside/Planetside.tscn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("Interact"):
		var childArray = get_node("../../../..").get_children()
		GalaxySave.setLastPlanetClicked(GalaxySave.getLastStarClicked(),childArray.find(self,0))
		# uses star position and position of planet to uniquely set up city pattern
		get_tree().change_scene("res://MapUIs/Planetside/Planetside.tscn")
