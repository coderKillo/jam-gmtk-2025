extends Node2D

@export var rotation_speed_range = Vector2(0, -6)
@export var radius_range = Vector2(-512, -530)

var rotation_speed = 0.0


func _ready():
	_generate_random()


func _process(delta):
	rotation_degrees += rotation_speed * delta


func _generate_random():
	$Sprite2D.frame = randi_range(0, 4)
	rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y)
	$Sprite2D.position.y = randi_range(radius_range.x, radius_range.y)
