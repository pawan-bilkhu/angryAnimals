extends Node

const DEFAULT_SCORE: int = 0

var _level_scores: Dictionary = {
	
}
var _selected_level: int = 0
var _attempts: int = 0
var _platforms_destroyed: int = 0
var _target_platforms: int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_platform_destoryed.connect(on_platform_destroyed)

func validate_level(level: int) -> void:
	if not _level_scores.has(level):
		_level_scores[level] = DEFAULT_SCORE


func selected_level(level: int) -> void:
	validate_level(level)
	_selected_level = level
	_attempts = 0
	_platforms_destroyed = 0
	print("_selected_level: %s _level_scores:%s" % [_selected_level, _level_scores])


func get_highest_score(level: int) -> int:
	validate_level(level)
	return _level_scores[level]


func get_attempts() -> int:
	return _attempts

func increment_attempt() -> void:
	_attempts += 1
	print("on_platform_destroyed() _target_platforms: %s, _attempts: %s, _platforms_destroyed: %s " % [
		_target_platforms, _attempts, _platforms_destroyed
		])
	SignalManager.on_attempt_made.emit()

func get_selected_level() -> int:
	return _selected_level

func set_target_platforms(targets: int) -> void:
	_target_platforms = targets
	print("_target_platforms: %s" % _target_platforms)

func validate_game_over() -> void:
	if _platforms_destroyed >= _target_platforms:
		var current_score = get_highest_score(_selected_level)
		if _attempts < current_score or current_score == DEFAULT_SCORE:
			_level_scores[_selected_level] = _attempts
			print("Record set: ", _level_scores)
		print("Game Over", _level_scores)
		SignalManager.on_game_over.emit()
		

func on_platform_destroyed() -> void:
	_platforms_destroyed += 1
	print("on_platform_destroyed() _target_platforms: %s, _attempts: %s, _platforms_destroyed: %s " % [
		_target_platforms, _attempts, _platforms_destroyed
		])
	validate_game_over()
