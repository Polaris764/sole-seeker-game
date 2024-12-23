extends Node2D

export (String,"horizontal","vertical") var orientation = "horizontal"
export var locked = true setget lock

onready var sprite = $Body/Sprite
onready var tween = $Tween
onready var static_body = $Body
onready var area = $Area2D
onready var openAudio = $doorOpenAudio
onready var closeAudio = $doorCloseAudio
var origin_pos = Vector2.ZERO
var coll_origin_pos = Vector2.ZERO
var dupe_origin_pos = Vector2.ZERO
var dupe

func _ready():
	origin_pos = position
	coll_origin_pos = area.position
	if orientation == "vertical":
		sprite.frame = 1
	else:
		sprite.frame = 0
	dupe = static_body.duplicate()
	add_child(dupe)
	dupe_origin_pos = dupe.position
	dupe.visible = false
	dupe.get_node("CollisionShape2D").disabled = true

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		open()


func open():
	if not locked:
		openAudio.play(1.5)
		tween.stop_all()
		if orientation == "vertical":
			#tween.interpolate_property(static_body, "position", static_body.position, Vector2(0,-24) + Vector2(0,56), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
			tween.interpolate_property(self, "position", self.position, origin_pos + Vector2(0,46), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property(dupe, "position", dupe.position, dupe_origin_pos + Vector2(0,-46), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property(area, "position", area.position, coll_origin_pos + Vector2(0,-46), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		else:
			tween.interpolate_property(self, "position", self.position, origin_pos + Vector2(-40,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property(dupe, "position", dupe.position, dupe_origin_pos + Vector2(40,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property(area, "position", area.position, coll_origin_pos + Vector2(40,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func close():
	if self.position != origin_pos or static_body.position != Vector2(0,-24):
		closeAudio.play(2.7)
	tween.stop_all()
	if orientation == "vertical":
		#tween.interpolate_property(static_body, "position", static_body.position, Vector2(0,-24) + Vector2(0,0), 1)
		
		tween.interpolate_property(self, "position", self.position, origin_pos + Vector2(0,0), 1)
		tween.interpolate_property(dupe, "position", dupe.position, dupe_origin_pos + Vector2(0,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(area, "position", area.position, coll_origin_pos + Vector2(0,0), 1)
	else:
		tween.interpolate_property(self, "position", self.position, origin_pos + Vector2(0,0), 1)
		tween.interpolate_property(dupe, "position", dupe.position, dupe_origin_pos + Vector2(0,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.interpolate_property(area, "position", area.position, coll_origin_pos + Vector2(0,0), 1)
	tween.start()

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		close()

func lock(value):
	if value:
		locked = true
		if dupe:
			dupe.get_node("CollisionShape2D").set_deferred("disabled",false)
		close()
	else:
		locked = false
		if dupe:
			dupe.get_node("CollisionShape2D").set_deferred("disabled",true)
