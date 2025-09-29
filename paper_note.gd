extends Area3D

@export var paper_note_ui_path : String = "res://paper_note_ui.tscn"
var ui_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_scene = load(paper_note_ui_path) as PackedScene

func _on_body_entered(body: Node3D) -> void:
	# Проверяем, что вошёл игрок
	if body.has_method("add_ammo"):
		var ui_instance = ui_scene.instantiate()
		ui_instance.set_player(body)
		get_tree().root.find_child("CanvasLayer", true, false).add_child(ui_instance)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		body.freeze()
		queue_free()
