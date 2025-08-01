extends Node2D

@export var health = 2

@onready var animation: AnimatedSprite2D = $FullTree/AnimatedSprite2D
@onready var full: StaticBody2D = $FullTree
@onready var small: StaticBody2D = $SmallTree
@onready var stamp: StaticBody2D = $Stamp


func _ready():
	full.hide()
	stamp.hide()
	small.show()


func grow():
	if not small.visible:
		return

	small.hide()
	small.get_node("CollisionShape2D").disabled = true
	full.show()
	full.get_node("CollisionShape2D").disabled = false


func hit():
	if health <= 0:
		return

	animation.play("hit")
	health -= 1
	if health <= 0:
		_died()


func _died():
	full.get_node("CollisionShape2D").disabled = true
	stamp.get_node("CollisionShape2D").disabled = false

	animation.play("fall")
	await animation.animation_finished

	full.hide()
	stamp.show()
