class_name Plant
extends Node2D

enum Stages { EMPTY = 0, HARVESTED = 1, STAGE4 = 2, STAGE3 = 3, STAGE2 = 4, STAGE1 = 5, KILL = 6 }
enum Plants { BEET, TOMATO, MELON, EGGPLANT, LEMON, PINEAPPLE, STRAWBERRY, POTATO, ORANGE, CORN }

var plant_frames = {
	Plants.BEET: [17, 0, 1, 2, 3, 4, 5],
	Plants.TOMATO: [17, 24, 25, 26, 27, 28, 29],
	Plants.MELON: [17, 30, 31, 32, 33, 34, 35],
	Plants.EGGPLANT: [17, 36, 37, 38, 39, 40, 41],
	Plants.LEMON: [17, 42, 43, 44, 45, 46, 47],
	Plants.STRAWBERRY: [17, 72, 73, 74, 75, 76, 77],
	Plants.POTATO: [17, 84, 85, 86, 87, 88, 89],
	Plants.ORANGE: [17, 96, 97, 98, 99, 100, 101],
	Plants.CORN: [17, 108, 109, 110, 111, 112, 113]
}

var is_watered := false
var current_stage := Stages.STAGE1
var plant_type := Plants.BEET

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D


func _ready():
	Events.day_time_changed.connect(_on_day_time_changed)
	Events.day_changed.connect(_on_day_changed)

	plant_type = plant_frames.keys().pick_random()

	_set_stage(Stages.EMPTY)

	area.body_entered.connect(_on_body_entered)


func _on_day_time_changed(_day_time):
	collision.disabled = false


func _on_day_changed(_day):
	if current_stage == Stages.EMPTY:
		return

	_next_stage()
	if is_watered:
		_next_stage()
	is_watered = false


func harvest():
	if current_stage == Stages.EMPTY:
		return
	collision.disabled = true
	if current_stage == Stages.STAGE4:
		_harvested()
	elif (
		current_stage == Stages.STAGE3
		or current_stage == Stages.STAGE2
		or current_stage == Stages.STAGE1
	):
		_killed()


func hit():
	if current_stage == Stages.EMPTY:
		return
	_killed()


func sow():
	if current_stage != Stages.EMPTY:
		return
	_set_stage(Stages.STAGE1)


func grow():
	if current_stage == Stages.EMPTY:
		return
	collision.disabled = true
	is_watered = true


func _next_stage():
	match current_stage:
		Stages.STAGE3:
			_set_stage(Stages.STAGE4)
		Stages.STAGE2:
			_set_stage(Stages.STAGE3)
		Stages.STAGE1:
			_set_stage(Stages.STAGE2)
		_:
			pass


func _set_stage(stage: Stages):
	sprite.frame = plant_frames[plant_type][int(stage)]
	current_stage = stage


func _killed():
	_set_stage(Stages.KILL)


func _harvested():
	_set_stage(Stages.HARVESTED)
	var tween = get_tree().create_tween()
	(
		tween
		. tween_property(self, "position:y", position.y - 60, 0.5)
		. from_current()
		. set_trans(Tween.TRANS_QUART)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween
		. tween_property(self, "position:y", position.y, 1.0)
		. from(position.y - 60)
		. set_trans(Tween.TRANS_BOUNCE)
		. set_ease(Tween.EASE_OUT)
	)

	await tween.finished
	collision.disabled = false


func _on_body_entered(_body):
	if current_stage != Stages.HARVESTED:
		return
	Events.plant_collected.emit(randi_range(100, 400))
	queue_free()
