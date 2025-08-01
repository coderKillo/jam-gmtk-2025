extends Node

@onready var scene_resource: SceneResource = preload("res://base/core/scenes/scenes.tres")

var main: Main
var current_level: Node
var pause_menu: OverlaidMenu


func _ready():
	Events.level_won.connect(_on_game_won)
	Events.level_lose.connect(_on_game_lose)

	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause_game()


func load_game_scene():
	main = scene_resource.main_scene.instantiate()
	var tree = get_tree()
	var current_scene = tree.current_scene

	tree.root.add_child(main)
	tree.root.remove_child(current_scene)
	current_scene.queue_free()
	tree.current_scene = main


func load_main_menu():
	get_tree().change_scene_to_packed(scene_resource.main_menu)
	main = null


func reload_level():
	load_level(GameState.get_current_level())


func advance_level():
	var next_level = GameState.get_current_level() + 1
	if next_level >= level_size():
		return

	load_level(next_level)


func level_size() -> int:
	return scene_resource.levels.size()


func load_level(level: int):
	assert(level < level_size())
	if not is_instance_valid(main):
		load_game_scene()

	GameState.set_current_level(level)

	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null

	current_level = scene_resource.levels[level].instantiate()

	if is_instance_valid(main.level_container):
		main.level_container.call_deferred("add_child", current_level)
	else:
		main.call_deferred("add_child", current_level)


func _on_game_won():
	if not is_instance_valid(main):
		return

	var scene = scene_resource.win_menu.instantiate()
	main.gui.add_child(scene)


func _on_game_lose():
	if not is_instance_valid(main):
		return

	var scene = scene_resource.lose_menu.instantiate()
	main.gui.add_child(scene)


func _pause_game():
	if not is_instance_valid(main):
		return

	if is_instance_valid(pause_menu):
		pause_menu.close()
	else:
		pause_menu = scene_resource.pause_menu.instantiate()
		main.gui.add_child(pause_menu)
