class_name MapMarker
extends RefCounted


var canvas_pos: Vector2
var map_pos: Vector2


func _init(canvas: Vector2, map: Vector2) -> void:
	canvas_pos = canvas
	map_pos = map
