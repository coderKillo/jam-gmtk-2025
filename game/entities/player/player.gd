class_name Player
extends Node2D

@export var jump_velocity = 300
@export var gravity = 300

@onready var character: CharacterBody2D = $CharacterBody2D
@onready var hitbox: Area2D = $CharacterBody2D/Area2D
@onready var animation: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var tool_container: Node2D = $CharacterBody2D/Tools
@onready var tools = {
	Global.Tools.GRAIN_SICKLE: $CharacterBody2D/Tools/Sickle,
	Global.Tools.SEED_BAG: $CharacterBody2D/Tools/Bag,
	Global.Tools.WATERING_CAN: $CharacterBody2D/Tools/Can,
	Global.Tools.WOOD_AXE: $CharacterBody2D/Tools/Axe,
}

var rotation_speed := 0
var selected_tool: Global.Tools:
	set = _set_selected_tool


func _ready():
	animation.frame_changed.connect(_frame_changed)


func _physics_process(delta):
	_process_movement(delta)


func _process_movement(delta):
	if not character.is_on_floor():
		character.velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump"):
		character.velocity.y = -jump_velocity
	character.move_and_slide()

	if character.move_and_collide(character.global_transform.x, true):
		pass
	elif Input.is_action_pressed("move_right"):
		_move(0.5, delta)
	elif Input.is_action_pressed("move_left"):
		_move(-2.0, delta)
	else:
		_move(0.0, delta)

	_update_animation()


func _move(value, delta):
	rotation_degrees += (1 + value) * rotation_speed * delta


func _update_animation():
	if character.is_on_floor():
		animation.play("run")
	elif character.velocity.y < 0:
		animation.play("jump")
	else:
		animation.play("fall")


func _set_selected_tool(value):
	selected_tool = value

	for _tool in tools.values():
		_tool.hide()

	tools[value].show()


func _frame_changed():
	if animation.animation != "run":
		return

	if (animation.frame % 2) == 0:
		tool_container.position.y = 2 * ((animation.frame % 4) - 1)
	else:
		tool_container.position.y = 1
