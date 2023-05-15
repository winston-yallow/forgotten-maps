class_name DynamicMap
extends Node2D


@export var texture: Texture
@export var size_factor: float = 1.0

var player_pos_debug := Vector2.ZERO
var placed_markers: Array[MapMarker] = []
var builder: MeshBuilder


func _add_marker(canvas_pos: Vector2, map_pos: Vector2) -> void:
	var marker := MapMarker.new(canvas_pos, map_pos)
	placed_markers.append(marker)
	if placed_markers.size() >= 3:
		builder = MeshBuilder.new(placed_markers, texture.get_size() * size_factor)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Show mesh
	if builder:
		draw_mesh(builder.mesh, texture)
	
	# Visualise mesh building
	if builder:
		var line_color := Color.MEDIUM_PURPLE
		var fill_color := line_color * Color(1, 1, 1, 0.3)
		var polygon_colors := [fill_color, fill_color, fill_color]
		for tri in builder.triangle_points:
			draw_line(tri[0], tri[1], line_color, 1.0)
			draw_line(tri[1], tri[2], line_color, 1.0)
			draw_line(tri[2], tri[0], line_color, 1.0)
			draw_polygon(tri, polygon_colors)
	
	# Draw markers
	for marker in placed_markers:
		draw_circle(marker.canvas_pos, 6.0, Color.GREEN)
		draw_line(marker.canvas_pos, marker.map_pos, Color.GREEN, 1.0)
	
	# Draw player position
	draw_circle(player_pos_debug, 10.0, Color.GOLD)
