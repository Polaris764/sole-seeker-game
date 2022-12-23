extends Camera2D

func _ready():
	self.position.y = get_node("../Player").position.y
	get_node("../Player").max_speed = 300
	get_node("../Player").rotation_speed = 1
	get_node("../Player").friction_weight = .1

func _process(_delta):
	var ship = get_node("../Player")
	var ship_pos = ship.position
	self.position = ship_pos
	
func zoom():

	if Input.is_action_just_released('zoom_out') and self.zoom.x < 15 and self.zoom.y < 15:
		self.zoom.x += 0.25
		self.zoom.y += 0.25
	if Input.is_action_just_released('zoom_in') and self.zoom.x > 1 and self.zoom.y > 1:
		self.zoom.x -= 0.25
		self.zoom.y -= 0.25

func _physics_process(_delta):
	zoom()
