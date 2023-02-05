extends Control

var hearts = 3 setget set_hearts
var max_hearts = 3 setget set_max_hearts #
onready var heart_image_array = [
	$HeartUIStage1, # least healthy state
	$HeartUIStage2, # \/ increasing health going down
	$HeartUIStage3 # more health states addable
]
var current_image = null

func set_hearts(value):
	print("setting hearts")
	hearts = clamp(value, 0, max_hearts)
	if current_image:
		current_image.visible = false
	print("hearts: " + str(hearts))
	print((hearts*float(heart_image_array.size())/max_hearts))
	print(int(round(hearts*float(heart_image_array.size())/max_hearts)))
	self.current_image = heart_image_array[int(round(hearts*float(heart_image_array.size())/max_hearts))-1]
	self.current_image.visible = true

func set_max_hearts(value):
	print("set max hearts")
	max_hearts = max(value,1)
	self.hearts = min(hearts,max_hearts)
	self.current_image = heart_image_array[int(round(hearts*float(heart_image_array.size())/max_hearts))-1]
	self.current_image.visible = true

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed",self,"set_hearts")
	PlayerStats.connect("max_health_changed",self,"set_max_hearts")
