extends Control


@onready var btn_menu: Button = %BtnMenu
@onready var mesh_instance: MeshInstance2D = %MeshInstance2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mesh_instance.texture = Data.texture
	mesh_instance.mesh = Data.mesh
	mesh_instance.position = (
		(Vector2(get_tree().root.size) - Data.texture.get_size())
		/ 2.0
	)
	btn_menu.pressed.connect(func():
		get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")
	)
