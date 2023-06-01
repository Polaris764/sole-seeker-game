extends Node2D

func _ready():
	$YSort/Player.isInRoom = true

func dictionary_merge(dict1,dict2):
	var new_dict = dict1
	for value in dict2:
		if value in dict1:
			new_dict[value] += dict2[value]
		else:
			new_dict[value] = dict2[value]
	return new_dict
