class_name Plant
extends Node2D

var color: Color = Color.WHITE:
	set(value):
		modulate = value
		color = value


func _ready():
	modulate = color
