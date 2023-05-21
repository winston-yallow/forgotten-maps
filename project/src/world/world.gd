extends Node3D


var load_steps_done := 0
var load_steps_total := 10

@onready var loading: Panel = %Loading
@onready var player: CharacterBody3D = %Player


func _ready() -> void:
	var nodes := get_tree().get_nodes_in_group("scatter")
	load_steps_total = nodes.size()
	for node in nodes:
		node.build_completed.connect(_complete_load_step)


func _complete_load_step() -> void:
	load_steps_done += 1
	print(load_steps_done, "/", load_steps_total)
	if load_steps_done == load_steps_total:
		player.loaded = true
		loading.queue_free()

