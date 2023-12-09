extends TextureButton

const HOVER_BUTTON_SCALAR: Vector2 = Vector2(1.2, 1.2)
const DEFAULT_BUTTON_SCALAR: Vector2 = Vector2(1, 1)
@export var level_number: int = 1

@onready var level_number_label = $MarginContainer/VBoxContainer/LevelNumberLabel
@onready var level_score_label = $MarginContainer/VBoxContainer/LevelScoreLabel

var _level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	level_number_label.text = str(level_number)
	# dynamically load a path that you aren't certain exists
	_level_scene = load("res://level/level_%s.tscn" % level_number)



func _on_pressed():
	# GameManager._load_level(level_number)
	get_tree().change_scene_to_packed(_level_scene)


func _on_mouse_entered():
	scale = HOVER_BUTTON_SCALAR


func _on_mouse_exited():
	scale = DEFAULT_BUTTON_SCALAR

