class_name DynamicMap
extends Control


@export var texture: Texture
@export var size_factor: float = 1.0
@export var player: Player

var proposed_marker := Vector2.INF
var placed_markers: Array[MapMarker] = []
var builder: MeshBuilder

@onready var rulers: Array[DraggableControl] = [
	%Ruler1 as DraggableControl,
	%Ruler2 as DraggableControl,
]
@onready var marker_add: Button = %MarkerAdd
@onready var click_detector: Control = %ClickDetector
@onready var marker_confirm: Button = %MarkerConfirm
@onready var marker_abort: Button = %MarkerAbort


func activate() -> void:
	visible = true
	click_detector.visible = false
	for ruler in rulers:
		ruler.activate()


func deactivate() -> void:
	visible = false
	click_detector.visible = false
	_end_marker_mode()
	for ruler in rulers:
		ruler.deactivate()


func is_active() -> bool:
	return visible


func add_marker(canvas_pos: Vector2, map_pos: Vector2) -> void:
	var marker := MapMarker.new(canvas_pos, map_pos)
	placed_markers.append(marker)
	if placed_markers.size() >= 3:
		builder = MeshBuilder.new(placed_markers, texture.get_size() * size_factor)


func _ready() -> void:
	marker_add.pressed.connect(_start_marker_mode)
	marker_abort.pressed.connect(_end_marker_mode)
	marker_confirm.pressed.connect(_confirm_marker)
	click_detector.gui_input.connect(_detector_input)


func _detector_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_interaction"):
		proposed_marker = get_local_mouse_position()
		marker_confirm.disabled = false


func _start_marker_mode() -> void:
	proposed_marker = Vector2.INF
	marker_confirm.disabled = true
	click_detector.visible = true
	marker_add.visible = false


func _end_marker_mode() -> void:
	proposed_marker = Vector2.INF
	click_detector.visible = false
	marker_add.visible = true


func _confirm_marker() -> void:
	add_marker(proposed_marker, player.get_map_pos())
	_end_marker_mode()


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
	if proposed_marker != Vector2.INF:
		draw_circle(proposed_marker, 8.0, Color.YELLOW_GREEN)
	for marker in placed_markers:
		draw_circle(marker.canvas_pos, 6.0, Color.GREEN)
		draw_line(marker.canvas_pos, marker.map_pos, Color.GREEN, 1.0)
	
	# Draw player position
	draw_circle(player.get_map_pos(), 10.0, Color.GOLD)
