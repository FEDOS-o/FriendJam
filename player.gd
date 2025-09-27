extends CharacterBody3D

const SPEED = 5.0
const CAMERA_SENS = 0.5

var rotate_left = false
var rotate_right = false

func _ready():
	# Инициализация игрока
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_left"):  # Клавиша Q
		rotate_left = true
	elif event.is_action_released("rotate_left"):
		rotate_left = false
	
	if event.is_action_pressed("rotate_right"):  # Клавиша E
		rotate_right = true
	elif event.is_action_released("rotate_right"):
		rotate_right = false

func _process(delta: float) -> void:
	# Обработка вращения
	if rotate_left and !rotate_right:
		rotation.y += CAMERA_SENS * delta
	elif rotate_right and !rotate_left:
		rotation.y -= CAMERA_SENS * delta

func _physics_process(delta: float) -> void:
	# Обработка движения
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = Vector3.ZERO
	direction.x = input_dir.x 
	direction.z = input_dir.y  
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

# Метод для получения позиции игрока (может понадобиться камере)
func get_player_position() -> Vector3:
	return global_position
