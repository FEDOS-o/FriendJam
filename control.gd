extends Control



@onready var button: Button = $Button


func _ready():
	# Подключаем сигнал нажатия кнопки
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	restart_game()

func restart_game():
	# Получаем текущую сцену
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path
	
	# Перезагружаем сцену
	get_tree().change_scene_to_file(scene_path)
	
	# Сбрасываем игровое состояние (дополнительные действия)
	reset_game_state()

func reset_game_state():
	
	# Сброс синглтонов
	reset_singletons()
	
	# Очистка инпута
	Input.action_release("ui_accept")
	Input.action_release("ui_cancel")
	
	# Восстанавливаем режим мыши
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset_singletons():
	# Пример сброса кастомных синглтонов
	if Engine.has_singleton("GameManager"):
		var game_manager = Engine.get_singleton("GameManager")
		if game_manager.has_method("reset"):
			game_manager.reset()
