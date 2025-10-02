extends CharacterBody3D

class_name Player

@onready var gun_sprite: AnimatedSprite2D = $CanvasLayer/VSplitContainer/FP/GunBase/GunSprite
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var cross_hair: ColorRect = $CanvasLayer/CrossHair
@onready var fp_viewport_container: SubViewportContainer = $CanvasLayer/FPViewportContainer
@onready var fp_camera: Camera3D = $FPCamera
@onready var ray_cast_3d: RayCast3D = $FPCamera/RayCast3D
@onready var ammo: Label = $CanvasLayer/VSplitContainer/FP/Ammo
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D


const MOUSE_SENS = 1
const SPEED = 500.0
const CAMERA_SENS = 0.5

var rotate_left = false
var rotate_right = false
var can_move = true 
var can_shoot = true

var current_ammo = 7
var max_ammo = 7
var reserve_ammo = 35
var max_reserve_ammo = 35

var health = 3
@onready var hp_hud: Sprite2D = $CanvasLayer/VSplitContainer/HpHud


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	gun_sprite.animation_finished.connect(_on_gun_shoot_finished)
	_setup_raycast()
	_update_ammo_display()

func _setup_raycast():
	#ray_cast_3d.debug_shape_thickness = 2
	#ray_cast_3d.debug_shape_custom_color = Color(1, 0, 0, 0.8)
	#ray_cast_3d.enabled = true
	
	# Устанавливаем начальную позицию RayCast (например, на оружии или камере)
	ray_cast_3d.global_position = fp_camera.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_left"):  # Клавиша Q
		rotate_left = true
	elif event.is_action_released("rotate_left"):
		rotate_left = false
	
	if event.is_action_pressed("rotate_right"):  # Клавиша E
		rotate_right = true
	elif event.is_action_released("rotate_right"):
		rotate_right = false
		
	if event is InputEventMouseMotion:
		var new_position = cross_hair.global_position + event.relative * MOUSE_SENS
		new_position.x = clamp(new_position.x, 0, fp_viewport_container.size.x)
		new_position.y = clamp(new_position.y, 0, fp_viewport_container.size.y)
		cross_hair.global_position = new_position
		_update_raycast_target()

func _process(delta: float) -> void:
	if !can_move: 
		return
	
	
	
	if rotate_left and !rotate_right:
		rotation.y += CAMERA_SENS * delta
	elif rotate_right and !rotate_left:
		rotation.y -= CAMERA_SENS * delta
		
	if Input.is_action_just_pressed("shoot"):
		_shoot()
		
	if Input.is_action_pressed("reload"):
		_reload()
		
	_update_raycast_target()
	

func _physics_process(delta: float) -> void:
	
	if !can_move:  # Блокируем движение во время перезарядки
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = Vector3.ZERO
	direction.x = input_dir.x 
	direction.z = input_dir.y  
	direction = direction.normalized()
	
	if direction:
		animated_sprite_3d.play("Walk")
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta
	else:
		animated_sprite_3d.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	
	move_and_slide()

func get_player_position() -> Vector3:
	return global_position
	
func freeze() -> void:
	can_move = false
	can_shoot = false
	
func unfreeze() -> void:
	can_move = true
	can_shoot = true

func _on_gun_shoot_finished() -> void:
	can_shoot = true

func _shoot() -> void:
	if !can_shoot:
		return
		
	if current_ammo <= 0:
		return	
		
	current_ammo -= 1
	_update_ammo_display()
	can_shoot = false
	gun_sprite.play("Shoot")
	shoot_sound.play()
	
	_handle_hit()
	
func _handle_hit():
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		
		if collider.has_method("die"):
			collider.die()
	
	
func _reload() -> void:
	if current_ammo >= max_ammo or reserve_ammo <= 0 or !can_move:
		return  
	
	can_move = false
	can_shoot = false
	
	gun_sprite.play("Reload")
	await gun_sprite.animation_finished
	
	var ammo_needed = max_ammo - current_ammo
	var ammo_to_reload = min(ammo_needed, reserve_ammo)
	
	current_ammo += ammo_to_reload
	reserve_ammo -= ammo_to_reload
	
	
	
	_update_ammo_display()
	
	can_move = true  # Разблокируем движение
	can_shoot = true

func add_ammo(amount: int) -> bool:
	if reserve_ammo == max_reserve_ammo:
		return false
	reserve_ammo = min(reserve_ammo + amount, max_reserve_ammo)
	_update_ammo_display()
	return true
	
func _update_ammo_display() -> void:
	ammo.text = "%d / %d" % [current_ammo, reserve_ammo]
	
func _update_raycast_target():
	var mouse_pos = cross_hair.global_position
	var viewport_container_size = fp_viewport_container.size
	
	var normalized_pos = mouse_pos / viewport_container_size
	
	var ray_origin = fp_camera.global_position
	var ray_direction = calculate_ray_direction(normalized_pos)
	
	ray_cast_3d.global_position = ray_origin
	ray_cast_3d.target_position = ray_direction * 1000
	ray_cast_3d.force_raycast_update()

func calculate_ray_direction(normalized_pos: Vector2) -> Vector3:
	var ndc = Vector2(
		normalized_pos.x * 2.0 - 1.0,
		(1.0 - normalized_pos.y) * 2.0 - 1.0 
	)
	
	var camera_transform = fp_camera.global_transform
	var camera_basis = camera_transform.basis
	
	var fov_rad = deg_to_rad(fp_camera.fov)
	var aspect = fp_viewport_container.size.aspect()
	
	var ray_dir_camera = Vector3(
		ndc.x * aspect * tan(fov_rad * 0.5),
		ndc.y * tan(fov_rad * 0.5),
		-1.0
	).normalized()
	
	return camera_basis * ray_dir_camera


func get_damage() -> void:
	health -= 1
	change_sprite_texture("res://assets/виньетка йоу %d хп.png" % health)
	if health <= 0:
		var new_path = "res://scenes/gamover.tscn"
		var ui_scene : PackedScene = load(new_path) as PackedScene
		var ui_instance = ui_scene.instantiate()
		get_tree().root.find_child("CanvasLayer", true, false).add_child(ui_instance)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		freeze()
		
func change_sprite_texture(new_texture_path: String) -> void:
	var new_texture = load(new_texture_path) as Texture2D
	hp_hud.texture = new_texture
	
