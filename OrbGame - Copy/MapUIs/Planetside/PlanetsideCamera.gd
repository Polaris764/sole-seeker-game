extends Camera2D

func _ready():
	self.position.y = get_node("../Player").position.y

func _process(_delta):
	var ship = get_node("../Player")
	var ship_pos = ship.position
	self.position = ship_pos

	var screen_size = get_viewport().size.y
	#if ship_pos.y < self.position.y - screen_size/1.9:
		#ship.position.y = self.position.y + screen_size/1.9
	#if ship_pos.y > self.position.y + screen_size/1.9:
		#ship.position.y = self.position.y - screen_size/1.9
