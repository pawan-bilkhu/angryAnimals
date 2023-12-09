extends Node

var main_scene: PackedScene = preload("res://main/main_menu.tscn")
const GROUP_PLATFORM: String = "platform"
const GROUP_ANIMAL: String = "animal"
#var levels: Array = [
	#preload("res://level/level_1.tscn"), 
	#preload("res://level/level_2.tscn"), 
	#preload("res://level/level_3.tscn")
	#]

#func _load_level(level_number: int)->void:
	#if level_number > levels.size():
		#return
	#get_tree().change_scene_to_packed(levels[level_number-1])
func load_main_scene()->void:
	get_tree().change_scene_to_packed(main_scene)
