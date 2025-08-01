extends Node2D

@export var health = 1

@onready var animation: AnimatedSprite2D = $FullTree/AnimatedSprite2D
@onready var full: StaticBody2D = $FullTree
@onready var small: StaticBody2D = $SmallTree
@onready var stamp: StaticBody2D = $Stamp

var is_watered := false


func _ready():
	full.hide()
	stamp.hide()
	small.show()

	Events.day_changed.connect(_on_day_changed)
	Events.day_time_changed.connect(_on_day_time_changed)


func _on_day_changed(_day):
	_grow()
	if stamp.visible:
		queue_free()


func _on_day_time_changed(_day_time):
	if is_watered:
		_grow()


func grow():
	is_watered = true


func _grow():
	if not small.visible:
		return

	small.hide()
	small.get_node("CollisionShape2D").disabled = true
	full.show()
	full.get_node("CollisionShape2D").disabled = false


func hit():
	if not full.visible:
		return

	if health <= 0:
		return

	animation.play("hit")
	health -= 1
	if health <= 0:
		_died()


func _died():
	full.get_node("CollisionShape2D").set_deferred("disabled", true)

	animation.play("fall")
	await animation.animation_finished

	if full.visible:
		Events.plant_collected.emit(500)

	full.hide()
	stamp.show()
