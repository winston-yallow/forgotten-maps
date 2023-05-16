class_name DraggableControl
extends Control


var active := false

var dragging := false
var drag_object_start := Vector2.ZERO
var drag_mouse_start := Vector2.ZERO

var rotating := false
var rotation_anchor := Vector2(0, size.y)


func activate() -> void:
	active = true
	dragging = false
	rotating = false


func deactivate() -> void:
	active = false


func _gui_input(event: InputEvent) -> void:
	if not active:
		return
	
	if not dragging:
		_handle_waiting(event)
	else:
		_handle_dragging(event)


func _handle_waiting(event: InputEvent) -> void:
	if event.is_action_pressed("map_interaction"):
		dragging = true
		rotating = false
		drag_object_start = position
		drag_mouse_start = event.global_position
		get_tree().root.set_input_as_handled()


func _handle_dragging(event: InputEvent) -> void:
	if event.is_action_released("map_interaction"):
		dragging = false
		get_tree().root.set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		
		if event.shift_pressed and not rotating:
			rotating = true
		elif not event.shift_pressed and rotating:
			rotating = false
			drag_object_start = position
			drag_mouse_start = event.global_position
		
		if rotating:
			var before := get_global_transform() * rotation_anchor
			var dir := before.direction_to(event.global_position)
			rotation = dir.angle()
			var after := get_global_transform() * rotation_anchor
			position -= after - before
		else:
			var diff: Vector2 = event.global_position - drag_mouse_start
			position = drag_object_start + diff
			get_tree().root.set_input_as_handled()
