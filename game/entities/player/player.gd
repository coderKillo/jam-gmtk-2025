class_name Player
extends Node2D

@export var jump_velocity = 300
@export var gravity = 300

@onready var character: CharacterBody2D = $CharacterBody2D
@onready var hitbox: Area2D = $CharacterBody2D/Area2D
@onready var hitbox_collision: CollisionShape2D = $CharacterBody2D/Area2D/CollisionShape2D
@onready var animation: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var tool_container: Node2D = $CharacterBody2D/Tools
@onready var tools = {
	Global.Tools.GRAIN_SICKLE: $CharacterBody2D/Tools/Sickle,
	Global.Tools.SEED_BAG: $CharacterBody2D/Tools/Bag,
	Global.Tools.WATERING_CAN: $CharacterBody2D/Tools/Can,
	Global.Tools.WOOD_AXE: $CharacterBody2D/Tools/Axe,
}

var attacking := false
var tool_used := false
var rotation_speed := 0
var selected_tool: Global.Tools:
	set = _set_selected_tool


func _ready():
	animation.frame_changed.connect(_frame_changed)
	hitbox.area_entered.connect(_on_hitbox_hit)
	hitbox.body_entered.connect(_on_hitbox_hit)


func _physics_process(delta):
	_process_movement(delta)


func _process_movement(delta):
	# Jumping
	if not character.is_on_floor():
		character.velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump"):
		character.velocity.y = -jump_velocity
	character.move_and_slide()

	# Attacking
	if Input.is_action_pressed("action1") and not attacking:
		_attack()
	if Input.is_action_pressed("action2") and not attacking:
		_use_tool()

	# Movement
	if character.move_and_collide(character.global_transform.x, true) or attacking:
		pass
	elif Input.is_action_pressed("move_right"):
		_flip_h(false)
		_move(0.5, delta)
	elif Input.is_action_pressed("move_left"):
		_flip_h(true)
		_move(-2.0, delta)
	else:
		_move(0.0, delta)

	_update_animation()


func _flip_h(value):
	animation.flip_h = value
	for a in tools.values():
		a.flip_h = value
	hitbox.scale.x = -1 if value else 1


func _move(value, delta):
	rotation_degrees += (1 + value) * rotation_speed * delta


func _attack():
	attacking = true
	animation.play("attack")
	hitbox_collision.disabled = false
	await animation.animation_finished
	hitbox_collision.disabled = true
	attacking = false


func _use_tool():
	attacking = true
	tool_used = true
	tools[selected_tool].play("hit")
	animation.play("idle")
	hitbox_collision.disabled = false
	await tools[selected_tool].animation_finished
	hitbox_collision.disabled = true
	tools[selected_tool].play("default")
	attacking = false
	tool_used = false


func _update_animation():
	if attacking:
		return

	elif character.is_on_floor():
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


func _on_hitbox_hit(area):
	if not attacking:
		return
	var area_owner = area.owner as Node2D
	if not tool_used:
		if area_owner.has_method("hit"):
			area_owner.hit()

	match selected_tool:
		Global.Tools.GRAIN_SICKLE:
			if area_owner.has_method("harvest"):
				area_owner.harvest()
		Global.Tools.SEED_BAG:
			if area_owner.has_method("sow"):
				area_owner.sow()
		Global.Tools.WATERING_CAN:
			if area_owner.has_method("grow"):
				area_owner.grow()
