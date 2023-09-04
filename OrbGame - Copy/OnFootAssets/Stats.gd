extends Node

export (float) var harvest_duration = 3.5
export (int) var max_health = 1 setget set_max_health
export (int) var max_health_glass = 1 setget set_max_health
export (int) var health = max_health setget set_health
export var is_player = false

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health,max_health)
	emit_signal("max_health_changed",max_health)

func set_health(value):
	health = value
	emit_signal("health_changed",health)
	if is_player and GalaxySave.game_data.has("playerHealth"):
		GalaxySave.game_data["playerHealth"] = value
	if health <= 0:
		emit_signal("no_health")
		if not is_player:
			GalaxySave.game_data["totalKills"] += 1

func _ready():
	if not is_player:
		self.health = max_health
	elif GalaxySave.game_data.has("playerHealth"):
		self.health = GalaxySave.game_data["playerHealth"]
