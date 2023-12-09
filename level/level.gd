extends Node2D

var animal_scene: PackedScene = preload("res://AnimalRigidbody/animal_rigidbody.tscn")
@onready var debug_label = $DebugLabel
@onready var animal_starting_location = $AnimalStartingLocation

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_update_debug_label.connect(on_update_debug_label)
	SignalManager.on_animal_died.connect(on_animal_died)
	on_animal_died()


func _process(delta):
	if Input.is_key_pressed(KEY_Q):
		GameManager.load_main_scene()

func on_animal_died() -> void:
	var animal_sprite = animal_scene.instantiate()
	animal_sprite.global_position = animal_starting_location.global_position
	add_child(animal_sprite)
	
func on_update_debug_label(text: String)-> void:
	debug_label.text = text
