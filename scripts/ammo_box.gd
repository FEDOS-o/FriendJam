extends Area3D

@export var ammo_amount: int = 5

@export var rotation_speed: float = 1.0  # Скорость вращения
@export var rotation_axis: Vector3 = Vector3.UP  # Ось вращения (по умолчанию Y)
@onready var pick_up_sound: AudioStreamPlayer = $PickUpSound


func _process(delta):
	rotate(rotation_axis, rotation_speed * delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node3D) -> void:
	# Проверяем, что вошёл игрок
	if body.has_method("add_ammo"):
		# Даём патроны игроку
		
		if body.add_ammo(ammo_amount):
			pick_up_sound.play()
			await pick_up_sound.finished
			queue_free()
