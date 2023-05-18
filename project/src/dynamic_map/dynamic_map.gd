class_name DynamicMap
extends Control


@export var texture: Texture:
	set(value):
		texture = value
		mesh_instance.texture = texture
@export var size_factor: float = 1.0
@export var player: Player

var proposed_marker := Vector2.INF
var placed_markers: Array[MapMarker] = []

@onready var mesh_instance: MeshInstance2D = %MeshInstance
@onready var rulers: Array[DraggableControl] = [
	%Ruler1 as DraggableControl,
	%Ruler2 as DraggableControl,
]
@onready var marker_add: Button = %MarkerAdd
@onready var click_detector: Control = %ClickDetector
@onready var marker_preview: Sprite2D = %MarkerPreview
@onready var btn_marker_confirm: Button = %MarkerConfirm
@onready var btn_marker_abort: Button = %MarkerAbort


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
	_rebuild_mesh()


func _ready() -> void:
	marker_add.pressed.connect(_start_marker_mode)
	btn_marker_abort.pressed.connect(_end_marker_mode)
	btn_marker_confirm.pressed.connect(_confirm_marker)
	click_detector.gui_input.connect(_detector_input)


func _detector_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_interaction"):
		proposed_marker = get_local_mouse_position()
		btn_marker_confirm.disabled = false
		marker_preview.visible = true
		marker_preview.position = proposed_marker


func _start_marker_mode() -> void:
	proposed_marker = Vector2.INF
	btn_marker_confirm.disabled = true
	click_detector.visible = true
	marker_add.visible = false
	marker_preview.visible = false


func _end_marker_mode() -> void:
	proposed_marker = Vector2.INF
	click_detector.visible = false
	marker_add.visible = true


func _confirm_marker() -> void:
	add_marker(proposed_marker, player.get_map_pos())
	_end_marker_mode()


func _rebuild_mesh() -> void:
	if placed_markers.size() < 3:
		return
	mesh_instance.mesh = MeshBuilder.from_markers(
		placed_markers,
		texture.get_size() * size_factor
	)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Draw player position
	if get_tree().debug_navigation_hint:
		draw_circle(player.get_map_pos(), 10.0, Color.GOLD)
