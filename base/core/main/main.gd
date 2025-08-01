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
@onready var background: Sprite2D = $World/Background
@onready var death_zone: Area2D = $World/DeathZone

var current_day = 1
var score = 0
var current_game_state := GameStates.INIT
var current_day_time := Global.DayTime.MORNING


func _ready():
	player.rotation_speed = rotation_speed
	spawner.planet = planet

	Events.plant_collected.connect(_on_plants_collected)
	death_zone.body_entered.connect(_on_death_zone_body_entered)


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
			pass


func _init_game():
	player.selected_tool = Global.Tools.SEED_BAG
	gui.set_score(score)
	_open_barn()


func _tool_selection():
	current_game_state = GameStates.TOOL_SELECTION
	gui.start_selection()


func _wait_for_tool_selected():
	if gui.is_selecting():
		return
	player.selected_tool = gui.get_selected_tool()
	_open_barn()


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
	spawner.start()


func _running(delta):
	rotation_axis.rotation_degrees -= rotation_speed * delta
	if player.rotation_degrees >= 360:
		player.rotation_degrees = 0
		rotation_axis.rotation_degrees = 0
		_close_barn()


func _close_barn():
	spawner.stop()
	current_game_state = GameStates.CLOSE_BARN
	player.set_physics_process(false)
	player.animation.play("hide")

	await player.animation.animation_finished

	player.hide()
	planet.barn.play("close")


func _wait_for_barn_close():
	if player.visible or planet.barn.is_playing():
		return

	match current_day_time:
		Global.DayTime.MORNING:
			_set_day_time(Global.DayTime.NOON)
			_tool_selection()
		Global.DayTime.NOON:
			_set_day_time(Global.DayTime.EVENING)
			_tool_selection()
		Global.DayTime.EVENING:
			_set_day_time(Global.DayTime.NIGHT)
			_night()
		_:
			pass


func _night():
	current_game_state = GameStates.NIGHT
	_next_day()
	await get_tree().create_timer(2.0).timeout
	_set_day_time(Global.DayTime.MORNING)
	_tool_selection()


func _set_day_time(day_time: Global.DayTime):
	current_day_time = day_time
	gui.set_day_time(current_day_time)
	match current_day_time:
		Global.DayTime.MORNING:
			background.modulate.v = 0.85
		Global.DayTime.NOON:
			background.modulate.v = 1.0
		Global.DayTime.EVENING:
			background.modulate.v = 0.6
		Global.DayTime.NIGHT:
			background.modulate.v = 0.4
	Events.day_changed.emit(current_day_time)


func _next_day():
	current_day += 1
	Events.day_changed.emit(current_day)
	rotation_speed += 2
	player.rotation_speed = rotation_speed


func _on_plants_collected(value: int):
	score += value * current_day
	gui.set_score(score)
	GameState.set_current_score(score)


func _on_death_zone_body_entered(body):
	if body.owner is Player:
		Events.level_lose.emit()
