extends Node2D

@onready var plant_scene = preload("res://game/entities/objects/plants/plant.tscn")
@onready var tree_scene = preload("res://game/entities/objects/trees/tree.tscn")

var timer: Timer
var planet: Planet


func _ready():
	timer = Timer.new()
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	add_child(timer)


func start():
	timer.start(1.0)


func stop():
	timer.stop()


func _on_timeout():
	var slot = planet.get_closest_slot(global_position)
	if await planet.is_slot_used(slot):
		timer.start(1.0)
		return

	var number = randi_range(0, 2)
	if number == 0:
		var plant := tree_scene.instantiate() as Node2D
		planet.set_node_to_slot(plant, slot)
	else:
		var plant := plant_scene.instantiate() as Node2D
		planet.set_node_to_slot(plant, slot)

	timer.start(float(randi() % 4))
