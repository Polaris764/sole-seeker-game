extends KinematicBody2D

export var max_speed = 70
onready var soft_collision = $SoftCollision
export var panicking = false setget set_panic

export var health = 1 setget check_health

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
			idle(delta)
		PANIC:
			run(delta)
		HIDE:
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

func idle(delta):
	velocity = move_and_slide(velocity*20*delta)

func crouch(delta):
	velocity = move_and_slide(velocity*20*delta)

func dead(_delta):
	$CollisionShape2D.disabled = true
	# change sprite to death animation
