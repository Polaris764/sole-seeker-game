extends KinematicBody2D

export var max_speed = 70
onready var soft_collision = $SoftCollision
export var panicking = false setget set_panic
onready var animationTree = $AnimationTree
onready var aState = animationTree.get("parameters/playback")
export var health = 1 setget check_health

export var skin_color : Color
export var shirt_color : Color
export var pants_color : Color
export var shoes_color : Color
export var hair_color : Color
export var hair_choice : int

export var destination1 : NodePath
export var destination2 : NodePath
export var destination3 : NodePath
export var destination4 : NodePath
var NodeD1
var NodeD2
var NodeD3
var NodeD4
var destination_table = []

func _ready():
	set_colors()
	if destination1:
		NodeD1 = get_node(destination1)
		destination_table.append(NodeD1)
	if destination2: 
		NodeD2 = get_node(destination2)
		destination_table.append(NodeD2)
	if destination3: 
		NodeD3 = get_node(destination3)
		destination_table.append(NodeD3)
	if destination4: 
		NodeD4 = get_node(destination4)
		destination_table.append(NodeD4)
func set_panic(value):
	panicking = value
	if value == true and state == IDLE:
		state = PANIC

func check_health(value):
	health += value
	if health < 1:
		state = DEAD

enum{
	IDLE,
	PANIC,
	HIDE,
	DEAD
}

var state = IDLE
var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity = Vector2.ZERO
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector()*delta*400
	match state:
		IDLE:
			aState.travel("Idle")
			idle(delta)
		PANIC:
			aState.travel("Walking")
			run(delta)
		HIDE:
			aState.travel("Idle")
			crouch(delta)
		DEAD:
			dead(delta)

var current_destination = 0
func run(delta):
	if global_position.distance_to(destination_table[current_destination].global_position) < 1:
		if destination_table.size() > (current_destination+1):
			current_destination += 1 # go to next destination
		else:
			state = HIDE
	velocity = global_position.direction_to(destination_table[current_destination].global_position)
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector()*delta*20
	velocity = move_and_slide(velocity*max_speed)
	animationTree.set("parameters/Walking/blend_position",velocity)
	animationTree.set("parameters/Idle/blend_position",velocity)
func idle(delta):
	velocity = move_and_slide(velocity*20*delta)

func crouch(delta):
	velocity = move_and_slide(velocity*20*delta)

onready var tween = $Tween
var played_death = false
func dead(_delta):
	if not played_death:
		played_death = true
		$CollisionShape2D.disabled = true
		animationTree.active = false
		tween.interpolate_property(self,"rotation",0,rand_choice(-PI/2,PI/2),.4)
		tween.start()
		print("started " + str(name))

func set_colors():
	var skin = $SkinSprite
	var shirt = $ShirtSprite
	var pants = $PantsSprite
	var shoes = $ShoeSprite
	var hair = $HairSprite
	match hair_choice:
		1:
			hair.texture = load("res://OnFootAssets/Village/VillagerHair1.png")
		2:
			hair.texture = load("res://OnFootAssets/Village/VillagerHair2.png")
		3:
			hair.texture = load("res://OnFootAssets/Village/VillagerHair3.png")
	var Sdupe = skin.material.duplicate()
	skin.material = Sdupe
	var Shdupe = shirt.material.duplicate()
	shirt.material = Shdupe
	var Pdupe = pants.material.duplicate()
	pants.material = Pdupe
	var Shoedupe = shoes.material.duplicate()
	shoes.material = Shoedupe
	var Hdupe = hair.material.duplicate()
	hair.material = Hdupe
	skin.material.set("shader_param/u_replacement_color", skin_color)
	shirt.material.set("shader_param/u_replacement_color", shirt_color)
	pants.material.set("shader_param/u_replacement_color", pants_color)
	shoes.material.set("shader_param/u_replacement_color", shoes_color)
	hair.material.set("shader_param/u_replacement_color", hair_color)

func rand_choice(option1,option2):
	var choice = randi()%2
	if choice == 0:
		return option1
	else:
		return option2

func _on_Interactable_interacted_with():
	SignalBus.emit_signal("display_dialogue",name)
