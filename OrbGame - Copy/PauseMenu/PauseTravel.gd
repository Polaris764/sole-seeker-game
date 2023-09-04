extends "res://PauseMenu/PauseBase.gd"

onready var galaxy_image_holder = $VBoxContainer/Container/ViewportContainer/Viewport/GalaxyImage
onready var loc_holder = $VBoxContainer/Container/StarsBox/VisitedBox/ScrollContainer/LocationHolder
onready var circle_image_holder = $VBoxContainer/Container/ViewportContainer/Viewport/CircleImage
onready var ship_image_holder = $VBoxContainer/Container/ViewportContainer/Viewport/ShipImage
onready var viewportContainer = $VBoxContainer/Container/ViewportContainer
onready var book_holder = $VBoxContainer/Container/StarsBox/BookmarkedBox/ScrollContainer/LocationHolder
func _ready():
	galaxy_image_holder.texture = create_galaxy_image()
func initialize():
	fill_trip_log()
	fill_bookmarks()
	add_ship_image()

func create_galaxy_image():
	var img  = Image.new()
	img.create(1080,1080,false,Image.FORMAT_RGBA8)
	img.fill(Color.black)
	img.lock()
	var rng = RandomNumberGenerator.new()
	rng.seed = (GalaxySave.game_data["galaxySeed"])
	for _i in range(4000):
		var radius = pow(rng.randf_range(2, 100),2)*ConstantsHolder.galaxy_size_var
		var angle = rng.randf_range(0, 2*PI)
		var new_location = Vector2.ZERO
		new_location.x = (cos(angle)*radius)
		new_location.y = (sin(angle)*radius)
		if abs(new_location.x)/100 < 540 and abs(new_location.y)/100 < 540:
			img.set_pixel(new_location.x/100+540,new_location.y/100+540,Color.white)
	var possible_arms = [0]#[0,11,7,12]
#	for i in rand_range(0,3):
#		possible_arms.pop_at(rand_range(0,possible_arms.size()-1))
	for i in range(0,10000):
		if possible_arms.has(i % 22):
			for _x in range(20):
				var planet_pos = ConstantsHolder.rotatePoint(i,i,rng)
				if abs(planet_pos.x)/100 < 540 and abs(planet_pos.y)/100 < 540:
					img.set_pixel(planet_pos.x/100+540,planet_pos.y/100+540,Color.white)
	img.unlock()
	var imagetex = ImageTexture.new()
	imagetex.create_from_image(img)
	return imagetex

func fill_trip_log():
	for button in loc_holder.get_children():
		button.queue_free()
	var button_scene = load("res://MainMenu/UIButtonBase.tscn")
	var log_array = GalaxySave.game_data["starsVisitedArray"]
	var log_dict = GalaxySave.game_data["starsVisitedDictionary"]
	var stars_added = 0
	for i in range(log_array.size()-1, -1, -1):
		stars_added += 1
		var star = log_array[i]
		var button_instance = button_scene.instance()
		var star_position = log_dict[star]
		var star_angle = rad2deg(Vector2(1,0).angle_to(star_position))
		if star_angle < 0:
			star_angle += 180
		button_instance.text = star + " (" + str(stepify(Vector2.ZERO.distance_to(star_position),.01)) + ", " + str(stepify(star_angle,.01)) + "°)"
		loc_holder.add_child(button_instance)
		button_instance.connect("pressed",self,"circle_star",[log_dict[star]])
		if stars_added >= 20:
			break

func fill_bookmarks():
	for button in book_holder.get_children():
		button.queue_free()
	var button_scene = load("res://MainMenu/UIButtonBase.tscn")
	var book_array = GalaxySave.game_data["bookmarkedStars"]
	var stars_added = 0
	for i in range(book_array.size()-1, -1, -1):
		stars_added += 1
		var star = book_array.keys()[i]
		var button_instance = button_scene.instance()
		var star_position = book_array[star]
		var star_angle = rad2deg(Vector2(1,0).angle_to(star_position))
		if star_angle < 0:
			star_angle += 180
		button_instance.text = star + " (" + str(stepify(Vector2.ZERO.distance_to(star_position),.01)) + ", " + str(stepify(star_angle,.01)) + "°)"
		book_holder.add_child(button_instance)
		button_instance.connect("pressed",self,"circle_star",[book_array[star]])
		if stars_added >= 20:
			break

func add_ship_image():
	var img = Image.new()
	img.create(1080,1080,false,Image.FORMAT_RGBA8)
	img.lock()
	var pos = GalaxySave.game_data["shipPosition"][0]
	var ship_points = [Vector2(-4,-2),Vector2(-3,-2),Vector2(-2,-2),Vector2(-1,-2),Vector2(0,-2),Vector2(-3,-1),Vector2(-2,-1),Vector2(2,-1),
	Vector2(-4,2),Vector2(-3,2),Vector2(-2,2),Vector2(-1,2),Vector2(0,2),Vector2(-3,1),Vector2(-2,1),Vector2(2,1),
	Vector2(-1,0),Vector2(0,0),Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0)]
	var ship_points2 = [Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),Vector2(-1,1),Vector2(0,1),Vector2(1,1),Vector2(-4,0),Vector2(-3,0),Vector2(-2,0),]
	for point in ship_points:
		img.set_pixel(pos.x/100+540+point.x,pos.y/100+540+point.y,Color.darkblue)
	for point in ship_points2:
		img.set_pixel(pos.x/100+540+point.x,pos.y/100+540+point.y,Color.gray)
	img.unlock()
	var imgtex = ImageTexture.new()
	imgtex.create_from_image(img)
	ship_image_holder.texture = imgtex

#func create_path():
#	var stars = 9
#	if locations.size() < 10:
#		stars = locations.size() - 1
#	for i in 9:
#		pass

onready var cImage = $VBoxContainer/Container/ViewportContainer/Viewport/CircleImage
func circle_star(pos):
	AudioManager.play_effect([AudioManager.effects.pauseClick])
	var img  = Image.new()
	img.create(1080,1080,false,Image.FORMAT_RGBA8)
	img.lock()
	var circle_points = [Vector2(-1,2),Vector2(0,2),Vector2(1,2),Vector2(2,1),Vector2(2,0),Vector2(2,-1),Vector2(-1,-2),Vector2(0,-2),Vector2(1,-2),Vector2(-2,-1),Vector2(-2,0),Vector2(-2,1),Vector2(-1,3),Vector2(0,3),Vector2(1,3),Vector2(3,1),Vector2(3,0),Vector2(3,-1),Vector2(-1,-3),Vector2(0,-3),Vector2(1,-3),Vector2(-3,-1),Vector2(-3,0),Vector2(-3,1),Vector2(2,2),Vector2(2,-2),Vector2(-2,2),Vector2(-2,-2)]
	var line_points = [Vector2(0,5),Vector2(0,6),Vector2(0,7),Vector2(0,8),Vector2(0,-5),Vector2(0,-6),Vector2(0,-7),Vector2(0,-8),Vector2(5,0),Vector2(6,0),Vector2(7,0),Vector2(8,0),Vector2(-5,0),Vector2(-6,0),Vector2(-7,0),Vector2(-8,0)]
	for point in circle_points:
		img.set_pixel(pos.x/100+540+point.x,pos.y/100+540+point.y,Color.darkcyan)
	for point in line_points:
		img.set_pixel(pos.x/100+540+point.x,pos.y/100+540+point.y,Color.darkcyan)
	img.unlock()
	var imgtex = ImageTexture.new()
	imgtex.create_from_image(img)
	cImage.texture = imgtex

func _physics_process(_delta):
	zoom()
func _input(event):
	if mouse_location:
		if event is InputEventMouseMotion and Input.is_action_pressed("attack"):
			mapCam.position -= event.relative / (mapCam.zoom*2)
		else:
			zoom()

export var zoom_max : float = 3.7
export var zoom_min : float = .5
onready var viewport = $VBoxContainer/Container/ViewportContainer/Viewport
onready var mapCam = $VBoxContainer/Container/ViewportContainer/Viewport/Camera2D
func zoom():
	if mouse_location and visible:
		if Input.is_action_just_released('zoom_out') and mapCam.zoom.x < zoom_max:
			mapCam.zoom += Vector2(.2,.2)
		if Input.is_action_just_released('zoom_in') and mapCam.zoom.x > zoom_min:
			mapCam.zoom -= Vector2(.2,.2)
var mouse_location = false
onready var mDetection = $VBoxContainer/Container/MouseDetection
func _on_MouseDetection_mouse_entered():
	mouse_location = true
func _on_MouseDetection_mouse_exited():
	mouse_location = false

#func get_mouse_pos():
#	var p = mDetection.get_local_mouse_position()
#	var p_offsetted = p/mDetection.rect_size - Vector2(.5,.5)
#	var cam_view_size = viewport.size * mapCam.zoom
#	var desired_cam_movement = cam_view_size * p_offsetted
#	mapCam.position = desired_cam_movement + mapCam.position
#	print("cam offset target" + str(desired_cam_movement))
#	print("current cam position" + str(mapCam.position))
#	print("project cam position" + str(mapCam.position+desired_cam_movement))
#	return p
