extends Node2D

onready var contact_organism = "Blue"#ConstantsHolder.contact_organism
onready var contact_organism_file = ConstantsHolder.name_to_file[contact_organism]
onready var station_floor_sprite = $Floor
onready var entity_holder = $YSort

var orders = ["reverse direction","stab","capture","scan"]
var orders_completed = 0

var current_order
func _ready():
	setup_organism()
	create_order()

func setup_organism():
	var organism_scene = load(ConstantsHolder.name_to_scene[contact_organism])
	var organism = organism_scene.instance()
	entity_holder.add_child(organism)
	if organism.get("is_in_room") != null:
		organism.is_in_room = true
	organism.global_position = station_floor_sprite.texture.get_size()*.5
	organism.get_node("Stats").connect("no_health",self,"end_contact_mission")
	organism.get_node("Stats").connect("health_changed",self,"stab_completed")

func create_order():
	if orders_completed % 3 == 0:
		current_order = "stab"
	else:
		current_order = orders[randi()%orders.size()]

func complete_order(origin):
	if origin == current_order:
		orders_completed += 1
		create_order()

func stab_completed(value):
	print("stab completed")
	complete_order("stab")

func end_contact_mission():
	GalaxySave.game_data["storedBlood"][contact_organism.to_lower()] += orders_completed

# complete orders. Every order completed gives an extra resource from the organism.
# killing it early will fulfill fewer orders and give fewer resources
