extends Control

onready var buildings_list = $NinePatchRect/BuildingsList
onready var buildings_price_list = $NinePatchRect/BuildingsList2

onready var defenses_list = $NinePatchRect/DefensesList
onready var defenses_price_list = $NinePatchRect/DefensesList2

onready var resources_list = $NinePatchRect/ResourceList

var building_types = ConstantsHolder.building_types

var buildings_dictionary = {building_types.WALL:{"red":4,"blue":2},building_types.FLOOR:{"red":0,"blue":0}}

var defenses_dictionary = {building_types.LANDMINE:{"red":0,"blue":0},building_types.LASER:{"red":0,"blue":0},building_types.TURRET:{"red":0,"blue":0},building_types.CALTROPS:{"red":0,"blue":0}}

var cannon_dictionary = {building_types.CANNONBASE:{"red":0,"blue":0},building_types.CANNONTURRET:{"red":0,"blue":0},building_types.CANNONPOWER:{"red":0,"blue":0}}

func _ready():
	visible = false
	calibrate_options()
	

func calibrate_options():
	var backpack = GalaxySave.game_data["backpackBlood"]
	var stored = GalaxySave.game_data["storedBlood"]
	var complete_resources = dictionary_merge(backpack,stored)
	var resources_string = "Resources: "
	for i in complete_resources:
		if backpack.keys().find(i) == 0:
			resources_string += (str(i).capitalize()+": "+str(complete_resources[i]))
		else:
			resources_string += (", "+str(i).capitalize()+": "+str(complete_resources[i]))
		
	resources_list.text = resources_string
	var selected_resource
	var selected_list = 0
	if buildings_list.is_anything_selected():
		selected_resource = buildings_list.get_selected_items()
		selected_list = 1
	elif defenses_list.is_anything_selected():
		selected_resource = defenses_list.get_selected_items()
		selected_list = 2
	buildings_list.clear()
	defenses_list.clear()
	buildings_price_list.clear()
	defenses_price_list.clear()
	for resource in buildings_dictionary:
		buildings_list.add_item(building_types.keys()[resource].capitalize() + ", Owned: " + str(GalaxySave.game_data["storedBuildings"][resource]))
		buildings_price_list.add_item("Price: " + dictionary_as_string(buildings_dictionary[resource]))
		var affordable = true
		var player_resources = complete_resources
		for resource_type in ConstantsHolder.resource_types:
			if player_resources[resource_type] < buildings_dictionary[resource][resource_type]:
				affordable = false
		if not affordable:
			buildings_list.set_item_custom_fg_color(resource,Color(1,1,1,.5))
	if GalaxySave.game_data["storyProgression"] >= 22:
		for resource in cannon_dictionary:
			if GalaxySave.game_data["cannonPartsBought"][resource] == false:
				buildings_list.add_item(building_types.keys()[resource].capitalize() + ", Owned: " + str(GalaxySave.game_data["storedBuildings"][resource]))
			else:
				buildings_list.add_item(building_types.keys()[resource].capitalize() + ", Owned: " + str(GalaxySave.game_data["storedBuildings"][resource]) + " (Max)")
			buildings_price_list.add_item("Price: " + dictionary_as_string(cannon_dictionary[resource]))
			var affordable = true
			var player_resources = complete_resources
			for resource_type in ConstantsHolder.resource_types:
				if player_resources[resource_type] < cannon_dictionary[resource][resource_type] or GalaxySave.game_data["cannonPartsBought"][resource] == true:
					affordable = false
			if not affordable:
				print("setting resource" + str(resource))
				buildings_list.set_item_custom_fg_color(resource,Color(1,1,1,.5))
	for resource in defenses_dictionary:
		defenses_list.add_item(building_types.keys()[resource].capitalize() + ", Owned: " + str(GalaxySave.game_data["storedBuildings"][resource]))
		defenses_price_list.add_item("Price: " + dictionary_as_string(defenses_dictionary[resource]))
		var affordable = true
		var player_resources = GalaxySave.game_data["backpackBlood"]
		for resource_type in ConstantsHolder.resource_types:
			if player_resources[resource_type] < defenses_dictionary[resource][resource_type]:
				affordable = false
		if not affordable:
			defenses_list.set_item_custom_fg_color(resource,Color(1,1,1,.5))
	if selected_list == 1:
		for item in selected_resource:
			buildings_list.select(item)
	elif selected_list == 2:
		for item in selected_resource:
			defenses_list.select(item)

func _on_BuildingsList_item_activated(index):
	var bought_item
	var cannon_item = false
	if index < buildings_dictionary.size():
		bought_item = buildings_dictionary.keys()[index]
	else:
		cannon_item = true
		bought_item = cannon_dictionary.keys()[index-buildings_dictionary.size()]
	var player_resources1 = GalaxySave.game_data["backpackBlood"]
	var player_resources2 = GalaxySave.game_data["storedBlood"]
	var player_resources = dictionary_merge(player_resources1,player_resources2)
	var affordable = true
	var resource_dictionary_to_use
	if cannon_item:
		resource_dictionary_to_use = cannon_dictionary
	else:
		resource_dictionary_to_use = buildings_dictionary
	for resource_type in ConstantsHolder.resource_types:
		if player_resources[resource_type] < resource_dictionary_to_use[bought_item][resource_type]:
			affordable = false
	if affordable:
		GalaxySave.game_data["storedBuildings"][bought_item] += 1
		for resource_type in ConstantsHolder.resource_types: #deducting price
			if player_resources1[resource_type] > resource_dictionary_to_use[bought_item][resource_type]:
				GalaxySave.game_data["backpackBlood"][resource_type] -= resource_dictionary_to_use[bought_item][resource_type]
			else:
				var price = resource_dictionary_to_use[bought_item][resource_type]
				var debt = price - player_resources1[resource_type]
				GalaxySave.game_data["backpackBlood"][resource_type] = 0
				GalaxySave.game_data["storedBlood"][resource_type] -= debt
		if cannon_item:
			GalaxySave.game_data["cannonPartsBought"][bought_item] = true
		GalaxySave.save_data()
		calibrate_options()

func _on_DefensesList_item_activated(index):
	var bought_item = defenses_dictionary.keys()[index]
	var player_resources1 = GalaxySave.game_data["backpackBlood"]
	var player_resources2 = GalaxySave.game_data["storedBlood"]
	var player_resources = dictionary_merge(player_resources1,player_resources2)
	var affordable = true
	for resource_type in ConstantsHolder.resource_types:
		if player_resources[resource_type] < defenses_dictionary[bought_item][resource_type]:
			affordable = false
	if affordable:
		GalaxySave.game_data["storedBuildings"][bought_item] += 1
		for resource_type in ConstantsHolder.resource_types: #deducting price
			if player_resources1[resource_type] > defenses_dictionary[bought_item][resource_type]:
				GalaxySave.game_data["backpackBlood"][resource_type] -= defenses_dictionary[bought_item][resource_type]
			else:
				var price = defenses_dictionary[bought_item][resource_type]
				var debt = price - player_resources1[resource_type]
				GalaxySave.game_data["backpackBlood"][resource_type] = 0
				GalaxySave.game_data["storedBlood"][resource_type] -= debt
		GalaxySave.save_data()
		calibrate_options()

func _on_BuildingsList_item_selected(_index):
	defenses_list.unselect_all()

func _on_DefensesList_item_selected(_index):
	buildings_list.unselect_all()

func _on_CloseButton_pressed():
	close_self()

#Tried to make push Interact to close menu. 
#Immediately opens menu again after pushing Interact. 
#Not worth fixing.
#func _unhandled_input(event):
#	if visible:
#		match event.get_class():
#			"InputEventKey":
#				if Input.is_action_just_pressed("Interact"):
#					close_self()

func close_self():
	visible = false
	get_tree().paused = false

func dictionary_merge(dict1,dict2):
	var new_dict = dict1.duplicate()
	for value in dict2:
		if value in dict1:
			new_dict[value] += dict2[value]
		else:
			new_dict[value] = dict2[value]
	return new_dict

func dictionary_as_string(dict):
	var new_string = ""
	var first = false
	for item in dict:
		if not first:
			new_string += (item.capitalize() + ": " + str(dict[item]))
			first = true
		else:
			new_string += (", " + item.capitalize() + ": " + str(dict[item]))
	return new_string

func _on_BuildingsList_gui_input(_event):
	buildings_price_list.get_v_scroll().value = buildings_list.get_v_scroll().value
