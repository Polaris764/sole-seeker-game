extends "res://PauseMenu/PauseBase.gd"

onready var galaxy_image_holder = $VBoxContainer/Container/ViewportContainer/Viewport/GalaxyImage
onready var loc_holder = $VBoxContainer/Container/StarsBox/VisitedBox/ScrollContainer/LocationHolder
onready var circle_image_holder = $VBoxContainer/Container/ViewportContainer/Viewport/CircleImage
onready var viewportContainer = $VBoxContainer/Container/ViewportContainer
onready var book_holder = $VBoxContainer/Container/StarsBox/BookmarkedBox/ScrollContainer/LocationHolder
func _ready():
	galaxy_image_holder.texture = create_galaxy_image()
func initialize():
	fill_trip_log()
	fill_bookmarks()

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
		button_instance.text = star
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
		button_instance.text = star
		book_holder.add_child(button_instance)
		button_instance.connect("pressed",self,"circle_star",[book_array[star]])
		if stars_added >= 20:
			break

#func create_path():
#	var stars = 9
#	if locations.size() < 10:
#		stars = locations.size() - 1
#	for i in 9:
#		pass

onready var cImage = $VBoxContainer/Container/ViewportContainer/Viewport/CircleImage
func circle_star(pos):
	print("creating circle")
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

export var zoom_max : float = 6
export var zoom_min = .7
	
func zoom():
	if mouse_location and visible:
		if Input.is_action_just_released('zoom_out') and galaxy_image_holder.rect_scale.x > zoom_min and galaxy_image_holder.rect_scale.y > zoom_min:
			galaxy_image_holder.rect_scale.x -= 0.2
			galaxy_image_holder.rect_scale.y -= 0.2
			circle_image_holder.rect_scale.x -= 0.2
			circle_image_holder.rect_scale.y -= 0.2
			#galaxy_image_holder.rect_pivot_offset = lerp(galaxy_image_holder.rect_pivot_offset,galaxy_image_holder.get_local_mouse_position(),.5)
		if Input.is_action_just_released('zoom_in') and galaxy_image_holder.rect_scale.x < zoom_max and galaxy_image_holder.rect_scale.y < zoom_max:
			galaxy_image_holder.rect_scale.x += 0.1
			galaxy_image_holder.rect_scale.y += 0.1
			circle_image_holder.rect_scale.x += 0.1
			circle_image_holder.rect_scale.y += 0.1
			var scale_factor = Vector2(1024,600)/get_viewport().size
			print(galaxy_image_holder.get_local_mouse_position())
			galaxy_image_holder.rect_pivot_offset = lerp(galaxy_image_holder.rect_pivot_offset,galaxy_image_holder.get_local_mouse_position()*scale_factor,.1)
			circle_image_holder.rect_pivot_offset = lerp(circle_image_holder.rect_pivot_offset,circle_image_holder.get_local_mouse_position()*scale_factor,.1)

var mouse_location = false
func _on_MouseDetection_mouse_entered():
	mouse_location = true
func _on_MouseDetection_mouse_exited():
	mouse_location = false
