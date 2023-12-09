extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var vanishing_sound = $VanishingSound


func destroy() -> void:
	vanishing_sound.play()
	animation_player.play("Vanish")


func _on_vanishing_sound_finished():
	SignalManager.on_platform_destoryed.emit()
	queue_free()
	
