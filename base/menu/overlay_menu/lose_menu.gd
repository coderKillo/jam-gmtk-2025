extends OverlaidMenu

@onready var description: RichTextLabel = %Text


func _ready():
	%MainMenu.pressed.connect(_on_main_menu_pressed)
	%Restart.pressed.connect(_on_restart_pressed)

	var score = GameState.get_score()
	var highscore = GameState.get_highscore()
	description.text = "score: %s\n highscore: %s" % [score, highscore]
	if score == highscore:
		description.text += "(new)"


func _on_main_menu_pressed():
	SceneManager.load_main_menu()
	close()


func _on_restart_pressed():
	SceneManager.load_game_scene()
	close()
