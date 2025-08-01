extends Node2D

@onready var area = $Area2D
@onready var plant_scene = preload("res://game/entities/objects/plants/plant.tscn")
@onready var tree_scene = preload("res://game/entities/objects/trees/tree.tscn")

var timer: Timer
var chance: int = 0
var rotation_axis: Node2D


func _ready():
	timer = Timer.new()
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	add_child(timer)
	timer.start(1.0)


func _on_timeout():
	if area.has_overlapping_areas():
		timer.start(1.0)
		return

	var plant := tree_scene.instantiate() as Node2D

	rotation_axis.add_child(plant)
	plant.global_rotation_degrees = area.global_rotation_degrees
	plant.global_position = area.global_position

	timer.start(float(randi() % 5))
