class_name Player
extends CharacterBody3D


const SPEED = 40.0
const JUMP_VELOCITY = 10.0
const GRAVITY = 30.0

@export var map_texture: Texture2D
@export var map_display_factor := 1.0
@export var map_world_offset := Vector2.ZERO
@export var map_world_scale := 1.0
@export var map_initial_markers: Array[Vector2] = []

@onready var cam: Camera3D = %Camera
@onready var map: DynamicMap = %DynamicMap
@onready var compass_bar: CompassBar = %CompassBar


func _ready() -> void:
	map.texture = map_texture
	map.size_factor = map_display_factor
	for pos in map_initial_markers:
		map.add_marker(pos, pos)
	_deactivate_map()


func get_map_pos() -> Vector2:
	return (Vector2(-position.x, -position.z) + map_world_offset) * map_world_scale


func _activate_map() -> void:
	map.activate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _deactivate_map() -> void:
	map.deactivate()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if map.is_active():
		if event.is_action_pressed("toggle_map"):
			_deactivate_map()
	else:
		if event.is_action_pressed("toggle_map"):
			_activate_map()
		elif event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.005)
			var new_cam_rotation: float = cam.rotation.x - event.relative.y * 0.005
			var max_rotation := deg_to_rad(80)
			cam.rotation.x = clamp(new_cam_rotation, -max_rotation, max_rotation)


func _physics_process(delta: float) -> void:
	if map.is_active():
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
