extends Camera2D

func _ready():
	self.position= get_node("../Player").position
onready var ship = get_node("../Player")
func _physics_process(_delta):
	var ship_pos = ship.position
	self.global_position = ship_pos
	GalaxySave.game_data["shipPosition"][1] = global_position
	zoom()

export var zoom_max = 5
export var zoom_min = .25
func zoom():
	if ship.functional:
		if Input.is_action_just_released('zoom_out') and self.zoom.x < zoom_max and self.zoom.y < zoom_max:
			self.zoom.x += 0.25
			self.zoom.y += 0.25
		if Input.is_action_just_released('zoom_in') and self.zoom.x > zoom_min and self.zoom.y > zoom_min:
			self.zoom.x -= 0.25
			self.zoom.y -= 0.25
