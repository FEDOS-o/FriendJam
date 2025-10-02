extends Area3D

@export var ammo_amount: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node3D) -> void:
	# Проверяем, что вошёл игрок
	if body.has_method("add_ammo"):
		# Даём патроны игроку
		if body.add_ammo(ammo_amount):
			queue_free()
