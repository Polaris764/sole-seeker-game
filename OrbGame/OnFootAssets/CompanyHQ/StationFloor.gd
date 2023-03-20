extends TileMap

onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = 5
	var grass_array = self.get_used_cells()
	for cell in grass_array:
		self.set_cell(cell.x,cell.y,rng.randi()%40,rand_bool(),rand_bool())

func rand_bool():
	if rng.randi()%2 == 0:
		return true
	else:
		return false
