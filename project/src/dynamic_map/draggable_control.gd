class_name DraggableControl
extends Control


enum STATE { NONE, DRAGGING, ROTATING }

var active := false
var current_state := STATE.NONE

var drag_object_start := Vector2.ZERO
var drag_mouse_start := Vector2.ZERO

var rotation_anchor := Vector2(0, size.y)


func activate() -> void:
	active = true


func deactivate() -> void:
	active = false


func _gui_input(event: InputEvent) -> void:
	if not active:
		return
	
	match current_state:
		STATE.NONE: _handle_waiting(event)
		STATE.DRAGGING: _handle_dragging(event)
		STATE.ROTATING: _handle_rotating(event)


func _handle_waiting(event: InputEvent) -> void:
	if event.is_action_pressed("map_interact_primary"):
		current_state = STATE.DRAGGING
		drag_object_start = position
		drag_mouse_start = event.global_position
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("map_interact_secondary"):
		current_state = STATE.ROTATING
		get_tree().root.set_input_as_handled()


func _handle_dragging(event: InputEvent) -> void:
	if event.is_action_released("map_interact_primary"):
		current_state = STATE.NONE
		get_tree().root.set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		var diff: Vector2 = event.global_position - drag_mouse_start
		position = drag_object_start + diff
		get_tree().root.set_input_as_handled()


func _handle_rotating(event: InputEvent) -> void:
	if event.is_action_released("map_interact_secondary"):
		current_state = STATE.NONE
		get_tree().root.set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		var before := get_global_transform() * rotation_anchor
		var dir := before.direction_to(event.global_position)
		rotation = dir.angle()
		var after := get_global_transform() * rotation_anchor
		position -= after - before
		get_tree().root.set_input_as_handled()
