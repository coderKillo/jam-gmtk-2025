class_name Gui
extends Control

signal tool_selected(value: Global.Tools)

@onready var score_label: Label = %ScoreText

@onready var day_time_textures = {
	Global.DayTime.MORNING: $DayTime/Early,
	Global.DayTime.NOON: $DayTime/Mid,
	Global.DayTime.EVENING: $DayTime/Late,
	Global.DayTime.NIGHT: $DayTime/Night,
}

@onready var tool_textures = [
	{
		position = 0,
		id = Global.Tools.SEED_BAG,
		node = $ToolSelection/HBoxContainer/BagSeed,
	},
	{
		position = 1,
		id = Global.Tools.WATERING_CAN,
		node = $ToolSelection/HBoxContainer/WateringCan,
	},
	{
		position = 2,
		id = Global.Tools.GRAIN_SICKLE,
		node = $ToolSelection/HBoxContainer/GrainSickle,
	},
]
@onready var tool_selector = $ToolSelection/Select_Animation
@onready var tool_selection = $ToolSelection

var _selected_position = 0:
	set = _set_selected_position


func _ready():
	pass


func _process(_delta):
	if tool_selection.visible:
		_process_selection()


func _process_selection():
	if Input.is_action_just_pressed("move_left"):
		_selected_position -= 1
	if Input.is_action_just_pressed("move_right"):
		_selected_position += 1
	if Input.is_action_just_pressed("jump"):
		tool_selected.emit(get_selected_tool())
		tool_selection.hide()

	tool_selector.position.x = lerp(
		tool_selector.position.x, tool_textures[_selected_position].position * 32.0, 0.5
	)


func start_selection():
	tool_selection.show()


func is_selecting():
	return tool_selection.visible


func get_selected_tool() -> Global.Tools:
	return tool_textures[_selected_position].id


func set_score(score: int):
	score_label.text = str(score)


func set_day_time(time: Global.DayTime):
	for texture in day_time_textures.values():
		texture.hide()
	day_time_textures[time].show()


func _set_selected_position(value):
	if value < 0 or value >= tool_textures.size():
		return
	_selected_position = value
