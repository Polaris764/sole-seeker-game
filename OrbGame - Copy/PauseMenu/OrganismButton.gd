extends TextureButton

func _ready():
	if not name in GalaxySave.game_data["enemiesContacted"]:
		disabled = true
		visible = true
