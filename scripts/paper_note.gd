extends Area3D

class_name PaperNote

@export var paper_note_ui_path : String = "res://scenes/papenotes/paper_note_%d.tscn"

static var current_num = 1

@export var rotation_speed: float = 1.0  # Скорость вращения
@export var rotation_axis: Vector3 = Vector3.UP  # Ось вращения (по умолчанию Y)


func _process(delta):
	rotate(rotation_axis, rotation_speed * delta)

func _on_body_entered(body: Node3D) -> void:
	# Проверяем, что вошёл игрок
	if body.has_method("add_ammo"):
		var new_path = paper_note_ui_path % current_num
		var ui_scene : PackedScene = load(new_path) as PackedScene
		current_num += 1
		var ui_instance = ui_scene.instantiate()
		ui_instance.set_player(body)
		get_tree().root.find_child("CanvasLayer", true, false).add_child(ui_instance)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		body.freeze()
		queue_free()
