extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 15.0
const GRAVITY = 30.0

@onready var cam: Camera3D = %Camera
@onready var map: DynamicMap = %DynamicMap


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not map.active:
		rotate_y(-event.relative.x * 0.005)
		var new_cam_rotation: float = cam.rotation.x - event.relative.y * 0.005
		var max_rotation := deg_to_rad(80)
		cam.rotation.x = clamp(new_cam_rotation, -max_rotation, max_rotation)
	
	elif event.is_action_pressed("toggle_map"):
		map.active = not map.active
		if map.active:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if map.active:
		return
	
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
