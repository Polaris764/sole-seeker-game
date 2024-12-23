extends CanvasLayer

onready var spaceship_level = GalaxySave.game_data["shipPosition"][2]

onready var spaceship_locations = ConstantsHolder.ship_locations

onready var current_spaceship_location = spaceship_locations.keys()[GalaxySave.game_data["shipPosition"][4]]

export var player : NodePath

func _ready():
	print("space ship level: " + str(spaceship_level))
	if spaceship_level == 0:
		$IncreaseLabel.disabled_message = "Max Speed Reached"
	elif spaceship_level == -2:
		$DecreaseLabel.interaction_result = "Exit Flight Chair"

func _on_IncreaseLabel_interacted_with():
	print("increasing")
	set_ship_rotation()
	if GalaxySave.game_data["shipPosition"][4] == ConstantsHolder.ship_locations.STATION:
		GalaxySave.set_ship_speed(2)
	else:
		GalaxySave.set_ship_speed(1)


func _on_DecreaseLabel_interacted_with():
	print("decreasing")
	set_ship_rotation()
	GalaxySave.set_ship_speed(-1)

func set_ship_rotation():
	GalaxySave.game_data["shipPosition"][3] = get_node("..").rotation
