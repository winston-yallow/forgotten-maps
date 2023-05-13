extends Node


const SPEED := 300.0;

@onready var player: Node3D = $Player


func _process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity := direction * SPEED
	player.position += Vector3(velocity.x, 0.0, velocity.y) * delta
