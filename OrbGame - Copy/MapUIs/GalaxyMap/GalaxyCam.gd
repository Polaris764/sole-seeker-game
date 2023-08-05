extends Camera2D

export var smoothspeed = 10
onready var ending = get_node("..").trigger_ending
func _ready():
	var ship = get_node("../Player")
	var ship_pos = ship.position
	position = ship_pos
	Engine.set_target_fps(Engine.get_iterations_per_second())

func _physics_process(_delta):
	var ship = get_node("../Player")
	var ship_pos = ship.position
	position = ship_pos.round() #lerp_overshoot_v(position,ship_pos,1,Vector2(1,1))
	GalaxySave.game_data["shipPosition"][0] = global_position
	#var scale := get_viewport_transform().get_scale()
	#self.position = (position * scale).floor() / scale
	zoom()

export var zoom_max = 15
export var zoom_min = .25
	
func zoom():
	if not ending:
		if Input.is_action_just_released('zoom_out') and self.zoom.x < zoom_max and self.zoom.y < zoom_max:
			self.zoom.x += 0.25
			self.zoom.y += 0.25
		if Input.is_action_just_released('zoom_in') and self.zoom.x > zoom_min and self.zoom.y > zoom_min:
			self.zoom.x -= 0.25
			self.zoom.y -= 0.25

# lerp to overshot target, without overshooting
static func lerp_overshoot(from: float, to: float, weight: float, overshoot: float) -> float:
	var d := (to - from) * weight
	
	if is_equal_approx(d, 0.0):
		return to
	
	var s := sign(d)
	var l: float = lerp(from, to + (overshoot * s), weight)
	
	if s == 1.0:
		l = min(l, to)
	elif s == -1.0:
		l = max(l, to)
	
	return l

# lerp to overshot target, without overshooting
static func lerp_overshoot_v(from: Vector2, to: Vector2, weight: float, overshoot: Vector2) -> Vector2:
	var x = lerp_overshoot(from.x, to.x, weight, overshoot.x)
	var y = lerp_overshoot(from.y, to.y, weight, overshoot.y)
	
	return Vector2(x,y)
