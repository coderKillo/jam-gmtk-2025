class_name Main
extends Control

enum GameStates { INIT, TOOL_SELECTION, OPEN_BARN, RUNNING, CLOSE_BARN, NIGHT }

@export var level_container: Node
@export var rotation_speed = 12

@onready var rotation_axis: Node2D = %RotationAxis
@onready var player: Player = %Player
@onready var planet: Planet = %Planet
@onready var spawner: Node2D = %Spawner
@onready var gui: Gui = %Gui

var current_day = 0
var current_game_state := GameStates.INIT


func _ready():
	player.rotation_speed = rotation_speed
	spawner.rotation_axis = rotation_axis


func _process(delta):
	match current_game_state:
		GameStates.INIT:
			_init_game()
		GameStates.TOOL_SELECTION:
			_wait_for_tool_selected()
		GameStates.OPEN_BARN:
			_wait_for_barn_open()
		GameStates.RUNNING:
			_running(delta)
		GameStates.CLOSE_BARN:
			_wait_for_barn_close()
		GameStates.NIGHT:
			_night()


func _init_game():
	player.selected_tool = Global.Tools.SEED_BAG
	_open_barn()


func _tool_selection():
	pass


func _wait_for_tool_selected():
	pass


func _open_barn():
	current_game_state = GameStates.OPEN_BARN
	player.set_physics_process(false)
	player.hide()
	planet.barn.play("open")

	await planet.barn.animation_finished

	player.show()
	player.animation.play("show")


func _wait_for_barn_open():
	if not player.visible or player.animation.is_playing():
		return

	player.set_physics_process(true)
	current_game_state = GameStates.RUNNING


func _running(delta):
	rotation_axis.rotation_degrees -= rotation_speed * delta


func _close_barn():
	pass


func _wait_for_barn_close():
	pass


func _night():
	pass
