extends Camera2D

func _ready():
	self.position.y = get_node("../Player").position.y

func _process(_delta):
	var ship = get_node("../Player")
	var ship_pos = ship.position
	self.position = ship_pos
	GalaxySave.game_data["shipPosition"][0] = global_position

export var zoom_max = 15
	
func zoom():

	if Input.is_action_just_released('zoom_out') and self.zoom.x < zoom_max and self.zoom.y < zoom_max:
		self.zoom.x += 0.25
		self.zoom.y += 0.25
	if Input.is_action_just_released('zoom_in') and self.zoom.x > 1 and self.zoom.y > 1:
		self.zoom.x -= 0.25
		self.zoom.y -= 0.25

func _physics_process(_delta):
	zoom()
