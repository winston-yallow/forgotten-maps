class_name Player
extends CharacterBody3D


const SPEED = 30.0
const JUMP_VELOCITY = 15.0
const GRAVITY = 30.0

@export var map_offset := Vector2.ZERO
@export var map_scale := 1.0

enum STATE { EXPLORING, MAPPING }
var current_state := STATE.EXPLORING

@onready var cam: Camera3D = %Camera
@onready var map: DynamicMap = %DynamicMap
@onready var compass_bar: CompassBar = %CompassBar


func _ready() -> void:
	_change_state(STATE.EXPLORING)


func get_map_pos() -> Vector2:
	return (Vector2(-position.x, -position.z) + map_offset) * map_scale


func _change_state(to: STATE) -> void:
	current_state = to
	match current_state:
		STATE.EXPLORING:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		STATE.MAPPING:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		_change_state(STATE.MAPPING if current_state == STATE.EXPLORING else STATE.EXPLORING)
	else:
		match current_state:
			STATE.EXPLORING:
				_handle_player_input(event)
			STATE.MAPPING:
				_handle_map_input(event)


func _handle_map_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_marker"):
		map._add_marker(event.position)


func _handle_player_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		var new_cam_rotation: float = cam.rotation.x - event.relative.y * 0.005
		var max_rotation := deg_to_rad(80)
		cam.rotation.x = clamp(new_cam_rotation, -max_rotation, max_rotation)


func _physics_process(delta: float) -> void:
	if current_state != STATE.EXPLORING:
		return
	
	# Update compass heading
	var forward := Vector2(basis.z.x, basis.z.z)
	compass_bar.heading = TAU - forward.angle_to(Vector2(0, -1))
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
