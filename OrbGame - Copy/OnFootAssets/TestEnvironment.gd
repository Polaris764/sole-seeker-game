extends Node2D

func _ready():
	$YSort/Player.isInRoom = true
	var dict1 = {"x":1,"y":1,"z":2}
	var dict2 = {"x":2,"y":3,"a":5}
	print(dictionary_merge(dict1,dict2))

func dictionary_merge(dict1,dict2):
	var new_dict = dict1
	for value in dict2:
		if value in dict1:
			new_dict[value] += dict2[value]
		else:
			new_dict[value] = dict2[value]
	return new_dict
