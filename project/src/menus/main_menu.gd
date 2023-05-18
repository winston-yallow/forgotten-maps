extends Control


const GAME_SCENE := preload("res://src/world/world.tscn")

@onready var btn_start: Button = %BtnStart
@onready var btn_options: Button = %BtnOptions
@onready var btn_credits: Button = %BtnCredits
@onready var btn_quit: Button = %BtnQuit

@onready var details: Panel = %Details
@onready var options: VBoxContainer = %Options
@onready var credits: VBoxContainer = %Credits


func _ready() -> void:
	btn_start.grab_focus()
	btn_start.pressed.connect(_load_scene.bind(GAME_SCENE))
	btn_options.pressed.connect(_click_details_button.bind(options))
	btn_credits.pressed.connect(_click_details_button.bind(credits))
	btn_quit.pressed.connect(get_tree().quit)


func _load_scene(packed_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(packed_scene)


func _click_details_button(details_menu: Control) -> void:
	if details_menu.visible:
		details.visible = false
		details_menu.visible = false
	else:
		details.visible = true
		options.visible = details_menu == options
		credits.visible = details_menu == credits
