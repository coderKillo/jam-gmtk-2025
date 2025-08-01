@tool
extends Line2D

@export var radius: float

@export_tool_button("Generate Lines", "Callable") var generate_lines_action = generate_lines


func generate_lines():
	clear_points()

	for i in 361:
		var angle = deg_to_rad(i)
		var point = Vector2(radius * cos(angle), radius * sin(angle))
		add_point(point)
