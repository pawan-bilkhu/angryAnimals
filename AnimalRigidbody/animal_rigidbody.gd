extends RigidBody2D

@onready var stretch_sound = $StretchSound
@onready var launch_sound = $LaunchSound
@onready var collide_sound = $CollideSound
@onready var arrow_sprite = $ArrowSprite


const MAXIMUM_DRAGGABLE_VECTOR: Vector2 = Vector2(0, 60)
const MINIMUM_DRAGGABLE_VECTOR: Vector2 = Vector2(-60, 0)
const IMPULSE_MAGNITUDE: float = 20.0
const MAXIMUM_IMPULSE_MAGNITUDE: float = 1200.0
const AIR_DURATION: float = 0.25
const MINIMUM_VELOCITY_TOLERANCE: float = 0.1


var _dead: bool = false
var _dragging_mouse: bool = false
var _release_mouse: bool = false
var _starting_animal_position: Vector2 = Vector2.ZERO
var _starting_mouse_position: Vector2 = Vector2.ZERO
var _current_mouse_position: Vector2 = Vector2.ZERO
# A Vector Quantity that represents the difference between the mouse starting position and it's current postion
var _launch_vector: Vector2 = Vector2.ZERO
var _air_time: float = 0.0
var _arrow_scale_x: float = 0.0
var _current_mouse_position_length: float = 0.0
var _last_collision_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_starting_animal_position = global_position
	_arrow_scale_x = arrow_sprite.scale.x
	arrow_sprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_debug_label()
	
	if _release_mouse:
		_air_time += delta
		if _air_time > AIR_DURATION:
			on_collision_play_sound()
			on_collide_platform()
	else:
		if not _dragging_mouse:
			return
		else:
			if Input.is_action_just_released("drag"):
				on_mouse_release()
			else:
				on_mouse_drag()

func update_debug_label() -> void:
	var debug_string = "global_position:%s contact_amount:%s\n" % [
		Utilities.vector2_to_str(global_position),
		get_contact_count()
		]
	debug_string += "_dragging_mouse:%s, _release_mouse:%s \n" % [
		_dragging_mouse,
		_release_mouse
	]
	debug_string += "_starting_animal_position:%s, _starting_mouse_position:%s, _launch_vector:%s \n" % [
		Utilities.vector2_to_str(_starting_animal_position),
		Utilities.vector2_to_str(_starting_mouse_position),
		Utilities.vector2_to_str(_launch_vector)
	]
	debug_string += "_current_mouse_position:%s, _current_mouse_position_length:%.1f \n" % [
		Utilities.vector2_to_str(_current_mouse_position),
		_current_mouse_position_length
	]
	debug_string += "angular_velocity:%.1f, linear_velocity:%s, _air_time:%.1f \n" % [
		angular_velocity,
		Utilities.vector2_to_str(linear_velocity),
		_air_time
	]
	SignalManager.on_update_debug_label.emit(debug_string)

func set_arrow_scale_and_rotation() -> void:
	var launch_vector_length = get_launch_vector().length()
	var launch_vector_proportion = launch_vector_length/MAXIMUM_IMPULSE_MAGNITUDE
	
	arrow_sprite.scale.x = (_arrow_scale_x * launch_vector_proportion) + _arrow_scale_x
	arrow_sprite.rotation = (_starting_animal_position - global_position).angle()


func on_animal_rolling_halt() -> bool:
	if get_contact_count() > 0:
		if (
			abs(linear_velocity.y) < MINIMUM_VELOCITY_TOLERANCE and 
			abs(angular_velocity) < MINIMUM_VELOCITY_TOLERANCE
		):
			return true
	return false
	
func on_collide_platform() -> void:
	if not on_animal_rolling_halt():
		return
	
	var colliding_bodies = get_colliding_bodies()
	if colliding_bodies.size() == 0:
		return
	
	var platform: CollisionObject2D = colliding_bodies[0]
	if platform.is_in_group(GameManager.GROUP_PLATFORM):
		platform.destroy()
		on_animal_die()
		
	
	
func on_collision_play_sound() -> void:
	if _last_collision_count == 0 and get_contact_count() > 0 and not collide_sound.playing:
		collide_sound.play()
	_last_collision_count = get_contact_count()
	
func on_mouse_down() -> void:
	_dragging_mouse = true
	_starting_mouse_position = get_global_mouse_position()
	_current_mouse_position = _starting_mouse_position
	arrow_sprite.show()
	
func on_mouse_drag() -> void:
	var global_mouse_position = get_global_mouse_position()
	_current_mouse_position_length = (_current_mouse_position - global_mouse_position).length()
	_current_mouse_position = global_mouse_position
	_launch_vector = global_mouse_position - _starting_mouse_position
	
	if _current_mouse_position_length > 0 and not stretch_sound.playing:
		stretch_sound.play()
		
	_launch_vector.x = clampf(
		_launch_vector.x,
		MINIMUM_DRAGGABLE_VECTOR.x,
		MAXIMUM_DRAGGABLE_VECTOR.x
	)
	_launch_vector.y = clampf(
		_launch_vector.y,
		MINIMUM_DRAGGABLE_VECTOR.y,
		MAXIMUM_DRAGGABLE_VECTOR.y
	)
	
	global_position = _starting_animal_position + _launch_vector
	set_arrow_scale_and_rotation()

func on_mouse_release() -> void:
	_dragging_mouse = false
	_release_mouse = true
	freeze = false
	apply_central_impulse(get_launch_vector())
	stretch_sound.stop()
	launch_sound.play()
	ScoreManager.increment_attempt()
	arrow_sprite.hide()

func get_launch_vector() -> Vector2:
	return _launch_vector * -1 * IMPULSE_MAGNITUDE

func on_animal_die() -> void:
	if _dead:
		return
	_dead = true
	SignalManager.on_animal_died.emit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	on_animal_die()


func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if _dragging_mouse or _release_mouse:
		return
	if event.is_action_pressed("drag"):
		on_mouse_down()
