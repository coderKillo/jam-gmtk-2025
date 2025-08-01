class_name OverlaidMenu
extends Control

@export var pauses_game: bool = true

var _initial_pause_state: bool = false
var _scene_tree: SceneTree


func close() -> void:
	_scene_tree.paused = _initial_pause_state
	queue_free()


func _enter_tree() -> void:
	_scene_tree = get_tree()
	_initial_pause_state = _scene_tree.paused
	if Engine.is_editor_hint():
		return
	_scene_tree.paused = pauses_game or _initial_pause_state
