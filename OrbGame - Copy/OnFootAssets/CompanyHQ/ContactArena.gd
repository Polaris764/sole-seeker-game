extends Node2D

onready var contact_organism_file = ConstantsHolder.contact_organism
onready var station_floor_sprite = $Floor
onready var entity_holder = $YSort
onready var atos_key = $YSort/ATOSfront/DialogueArea
onready var scan_hitbox = $YSort/Scanner/ScannerArea

var orders = ["reverse direction","stab","trap","scan","shower"]
var orders_completed = 0
var organism

var contact_over = false

var current_order
func _ready():
	if not contact_organism_file:
		var _new_scene = get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")
		print("Aborting contact mission.")
	else:
		AudioManager.play_song([AudioManager.songs.contact],"contact")
		setup_organism()
		create_order()
func _exit_tree():
	AudioManager.stop_song("contact")

func setup_organism():
	var organism_scene = load(ConstantsHolder.name_to_scene[ConstantsHolder.file_to_name[contact_organism_file]])
	organism = organism_scene.instance()
	entity_holder.add_child(organism)
	GalaxySave.game_data["capturedEnemies"].erase(contact_organism_file)
	if organism.get("is_in_room") != null:
		organism.is_in_room = true
	organism.global_position = station_floor_sprite.texture.get_size()*.5
	organism.get_node("Stats").connect("no_health",self,"end_contact_mission")
	organism.get_node("Stats").connect("health_changed",self,"stab_completed")
	organism.connect("direction_changed",self,"reverse_direction_completed")
	organism.connect("organism_trapped",self,"trap_completed")
	handle_organism_exceptions()

func handle_organism_exceptions():
	if contact_organism_file == "OrangeEnemy" or contact_organism_file == "PurpleEnemy":
		orders.erase("reverse direction")
		orders.erase("scan")
		orders.erase("shower")

func create_order():
	if orders_completed % 3 == 2:
		current_order = "stab"
	else:
		current_order = orders[randi()%orders.size()]
		if current_order == "reverse direction":
			organism.velocity_for_change = organism.velocity.normalized()
	match current_order:
		"stab":
			SignalBus.emit_signal("display_announcement","contact_order_stab")
			atos_key.dialogue_key = "atos_stab"
		"reverse direction":
			SignalBus.emit_signal("display_announcement","contact_order_reverse_direction")
			atos_key.dialogue_key = "atos_reverse_direction"
		"trap":
			SignalBus.emit_signal("display_announcement","contact_order_trap")
			atos_key.dialogue_key = "atos_trap"
		"scan":
			SignalBus.emit_signal("display_announcement","contact_order_scan")
			atos_key.dialogue_key = "atos_scan"
			if scan_hitbox.get_overlapping_bodies().size() > 0:
				yield(get_tree().create_timer(.5), "timeout")
				scan_completed()
		"shower":
			SignalBus.emit_signal("display_announcement","contact_order_shower")
			atos_key.dialogue_key = "atos_shower"

func complete_order(origin):
	if origin == current_order:
		orders_completed += 1
		if not contact_over:
			create_order()

func stab_completed(_value):
	complete_order("stab")
func reverse_direction_completed():
	complete_order("reverse direction")
func trap_completed():
	complete_order("trap")
func scan_completed():
	complete_order("scan")
func shower_completed():
	complete_order("shower")

func end_contact_mission():
	contact_over = true
	SignalBus.emit_signal("display_announcement","contact_ended")
	GalaxySave.game_data["enemiesContacted"].append(organism.name)
	GalaxySave.game_data["storedBlood"][ConstantsHolder.file_to_name[contact_organism_file].to_lower()] += orders_completed
	if GalaxySave.game_data["storyProgression"] == 14 and ConstantsHolder.file_to_name[contact_organism_file] == "Red":
		GalaxySave.game_data["storyProgression"] = 15
	elif GalaxySave.game_data["storyProgression"] == 17 and ConstantsHolder.file_to_name[contact_organism_file] == "Purple":
		GalaxySave.game_data["storyProgression"] = 18
# complete orders. Every order completed gives an extra resource from the organism.
# killing it early will fulfill fewer orders and give fewer resources

func _on_Interactable_interacted_with():
	var _change = get_tree().change_scene("res://OnFootAssets/CompanyHQ/CompanyHQInside.tscn")

func _on_ScannerArea_body_entered(_body):
	scan_completed()

func _on_Sprinkler_body_entered(_body):
	shower_completed()
