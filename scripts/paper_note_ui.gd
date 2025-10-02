extends Control

var player : Player

func _on_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.unfreeze()
	queue_free()

func set_player(body : Player) -> void:
	player = body
