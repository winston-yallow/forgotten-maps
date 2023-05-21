class_name DynamicMap
extends Control


const MAIN_MENU_SCENE := "res://src/menus/main_menu.tscn"
const MASK_TEXTURE := preload("res://src/dynamic_map/mask_texture.tres")

signal back_requested
signal marker_placed

@export var texture: Texture2D:
	set(value):
		texture = value
		mesh_instance.texture = texture
		mask_viewport.size = texture.get_size()
		mesh_instance.position = (
			(Vector2(get_tree().root.size) - texture.get_size())
			/ 2.0
		)
@export var size_factor: float = 1.0
@export var player: Player

var proposed_marker := Vector2.INF
var placed_markers: Array[MapMarker] = []

var map_dragging := false
var map_drag_offset := Vector2.ZERO

@onready var background: Control = %Background
@onready var mesh_instance: MeshInstance2D = %MeshInstance

@onready var rulers: Array[Ruler] = [
	%Ruler1 as Ruler,
	%Ruler2 as Ruler,
]

@onready var btn_marker_add: Button = %BtnMarkerAdd
@onready var click_detector: Control = %ClickDetector
@onready var marker_preview: Sprite2D = %MarkerPreview
@onready var btn_marker_confirm: Button = %MarkerConfirm
@onready var btn_marker_abort: Button = %MarkerAbort

@onready var mask_viewport: SubViewport = %MaskViewport

@onready var btn_back: Button = %BtnBack

@onready var menu: Control = %Menu
@onready var btn_menu: Button = %BtnMenu
@onready var btn_menu_continue: Button = %BtnMenuContinue
@onready var btn_menu_quit: Button = %BtnMenuQuit


func _ready() -> void:
	btn_back.pressed.connect(func(): back_requested.emit())
	
	btn_menu.pressed.connect(func(): menu.visible = true)
	btn_menu_continue.pressed.connect(func(): menu.visible = false)
	btn_menu_quit.pressed.connect(func():
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	)
	
	btn_marker_add.pressed.connect(_start_marker_mode)
	btn_marker_abort.pressed.connect(_end_marker_mode)
	btn_marker_confirm.pressed.connect(_confirm_marker)
	click_detector.gui_input.connect(_detector_input)
	background.gui_input.connect(_background_input)
	
	(mesh_instance.material as ShaderMaterial).set_shader_parameter(
		"mask_texture",
		mask_viewport.get_texture()
	)


func activate() -> void:
	visible = true
	click_detector.visible = false
	menu.visible = false
	for ruler in rulers:
		ruler.activate()


func deactivate() -> void:
	visible = false
	click_detector.visible = false
	menu.visible = false
	_end_marker_mode()
	for ruler in rulers:
		ruler.deactivate()


func is_active() -> bool:
	return visible


func add_marker(canvas_pos: Vector2, map_pos: Vector2) -> void:
	marker_placed.emit()
	var marker := MapMarker.new(canvas_pos, map_pos)
	placed_markers.append(marker)
	var mask_sprite := Sprite2D.new()
	mask_sprite.texture = MASK_TEXTURE
	mask_sprite.position = map_pos
	mask_viewport.add_child(mask_sprite)
	mask_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_rebuild_mesh()


func store_data() -> void:
	Data.texture = texture
	Data.mesh = mesh_instance.mesh
	Data.markers = placed_markers


func _background_input(event: InputEvent) -> void:
	if not map_dragging:
		if event.is_action_pressed("map_interact_primary"):
			map_dragging = true
			map_drag_offset = mesh_instance.position - event.position
	elif event.is_action_released("map_interact_primary"):
		map_dragging = false
	elif InputEventMouseMotion:
		mesh_instance.position = event.position + map_drag_offset


func _detector_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_interact_primary"):
		proposed_marker = get_local_mouse_position()
		btn_marker_confirm.disabled = false
		marker_preview.visible = true
		marker_preview.position = proposed_marker


func _start_marker_mode() -> void:
	proposed_marker = Vector2.INF
	btn_marker_confirm.disabled = true
	click_detector.visible = true
	btn_marker_add.visible = false
	marker_preview.visible = false


func _end_marker_mode() -> void:
	proposed_marker = Vector2.INF
	click_detector.visible = false
	btn_marker_add.visible = true


func _confirm_marker() -> void:
	add_marker(proposed_marker - mesh_instance.position, player.get_map_pos())
	_end_marker_mode()


func _rebuild_mesh() -> void:
	if placed_markers.size() < 3:
		return
	mesh_instance.mesh = MeshBuilder.from_markers(
		placed_markers,
		texture.get_size() * size_factor,
		MASK_TEXTURE.get_size().x
	)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Draw player position
	if get_tree().debug_navigation_hint:
		draw_circle(player.get_map_pos() + mesh_instance.position, 10.0, Color.GOLD)
