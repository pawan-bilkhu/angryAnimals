extends CanvasLayer

@onready var level_number_label = $MarginContainer/GameHUDVBoxContainer/LevelNumberLabel
@onready var attempt_number_label = $MarginContainer/GameHUDVBoxContainer/AttemptNumberLabel
@onready var game_over_v_box_container = $MarginContainer/GameOverVBoxContainer
@onready var completion_sound = $CompletionSound

# Called when the node enters the scene tree for the first time.
func _ready():
	level_number_label.text = "LEVEL: %s" % str(ScoreManager.get_selected_level())
	display_attempt()
	SignalManager.on_attempt_made.connect(display_attempt)
	SignalManager.on_game_over.connect(display_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_over_v_box_container.visible and Input.is_key_pressed(KEY_SPACE):
		GameManager.load_main_scene()
	
func display_game_over() -> void:
	game_over_v_box_container.show()
	completion_sound.play()

func display_attempt() -> void:
	attempt_number_label.text = "ATTEMPTS: %s" % str(ScoreManager.get_attempts())
