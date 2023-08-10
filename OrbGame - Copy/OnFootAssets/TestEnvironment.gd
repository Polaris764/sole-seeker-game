extends Node2D

func _ready():
	seed(123)
	var x = randi()
	var y = rand_range(300,800)
	var z = randi()
	print(z)
	seed(123)
	var a = randi()
	var b = rand_range(300,800)
	var c = randi()
	print(c)
	
	$YSort/Player.isInRoom = true

func dictionary_merge(dict1,dict2):
	var new_dict = dict1
	for value in dict2:
		if value in dict1:
			new_dict[value] += dict2[value]
		else:
			new_dict[value] = dict2[value]
	return new_dict
