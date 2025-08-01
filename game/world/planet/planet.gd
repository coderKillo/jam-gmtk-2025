class_name Planet
extends Node2D

@export var grid_size = 5
@export var spawn_radius = 513

@onready var barn: AnimatedSprite2D = $Barn
@onready var slot_checker: Area2D = $SlotChecker


func is_slot_used(slot: int):
	slot_checker.rotation_degrees = slot * grid_size
	await get_tree().physics_frame
	await get_tree().physics_frame
	return slot_checker.has_overlapping_areas()


func get_closest_slot(pos: Vector2):
	var angle = rad_to_deg(global_position.angle_to_point(pos)) - global_rotation_degrees
	var slot: int = int(angle / grid_size)
	return slot


func set_node_to_slot(node: Node2D, slot: int):
	var angle = slot * grid_size
	var point = Vector2(
		spawn_radius * cos(deg_to_rad(angle)), spawn_radius * sin(deg_to_rad(angle))
	)
	add_child(node)
	node.position = point
	node.rotation_degrees = angle + 90
