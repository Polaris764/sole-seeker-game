extends Control

onready var buildings_list = $NinePatchRect/BuildingsList

onready var defenses_list = $NinePatchRect/DefensesList

var building_types = ConstantsHolder.building_types

var buildings_dictionary = {building_types.WALL:{"red":0,"blue":0},building_types.FLOOR:{"red":0,"blue":0}}

var defenses_dictionary = {building_types.LANDMINE:{"red":0,"blue":0},building_types.LASER:{"red":0,"blue":0},building_types.TURRET:{"red":0,"blue":0},building_types.CALTROPS:{"red":0,"blue":0}}

func _ready():
	visible = false
	for resource in buildings_dictionary:
		buildings_list.add_item(building_types.keys()[resource])
	for resource in defenses_dictionary:
		defenses_list.add_item(building_types.keys()[resource])

func _on_BuildingsList_item_activated(index):
	var bought_item = buildings_dictionary.keys()[index]
	var player_resources = GalaxySave.game_data["backpackBlood"]
	var affordable = true
	for resource_type in ConstantsHolder.resource_types:
		if player_resources[resource_type] < buildings_dictionary[bought_item][resource_type]:
			affordable = false
	if affordable:
		print("item bought")
		GalaxySave.game_data["storedBuildings"][bought_item] += 1
		GalaxySave.save_data()

func _on_DefensesList_item_activated(index):
	var bought_item = defenses_dictionary.keys()[index]
	var player_resources = GalaxySave.game_data["backpackBlood"]
	var affordable = true
	for resource_type in ConstantsHolder.resource_types:
		if player_resources[resource_type] < defenses_dictionary[bought_item][resource_type]:
			affordable = false
	if affordable:
		print("item bought")
		GalaxySave.game_data["storedBuildings"][bought_item] += 1
		GalaxySave.save_data()
