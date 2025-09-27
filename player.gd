extends CharacterBody3D


@onready var animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/VSplitContainer/FP/GunBase/AnimatedSprite2D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var cross_hair: ColorRect = $CanvasLayer/CrossHair
@onready var fp_camera: Camera3D = $FPCamera
@onready var td_camera: Camera3D = $TDCamera
@onready var viewport_container: SubViewportContainer = $CanvasLayer/ViewportContainer
@onready var viewport_fp: SubViewport = $CanvasLayer/ViewportContainer/ViewportFP
@onready var viewport_td: SubViewport = $CanvasLayer/ViewportContainer/ViewportTD



const SPEED = 5.0
const MOUSE_SENS = 0.5
const CAMERA_SENS = 0.5

var shadow_fp: Camera3D
var shadow_td: Camera3D

var can_shoot = true
var rotate_left = false
var rotate_right = false

var screen_size = Vector2.ZERO

func _ready():
	_setup_split_screen()
	
func _setup_split_screen():
	viewport_container.anchors_preset = Control.PRESET_FULL_RECT
	viewport_container.size = get_viewport().get_visible_rect().size

	screen_size = viewport_container.size
	viewport_fp.size = Vector2(screen_size.x, screen_size.y / 2)
	viewport_td.size = Vector2(screen_size.x, screen_size.y / 2)

	viewport_fp.world_3d = get_world_3d()
	viewport_td.world_3d = get_world_3d()

	_setup_cameras()

func _setup_cameras():
	fp_camera.current = false
	td_camera.current = false
	_create_camera_shadows()

func _create_camera_shadows():
	shadow_fp = Camera3D.new()
	shadow_fp.name = "ShadowFP"
	viewport_fp.add_child(shadow_fp)
	shadow_fp.current = true

	shadow_td = Camera3D.new()
	shadow_td.name = "ShadowTD"
	viewport_td.add_child(shadow_td)
	shadow_td.current = true

	_copy_camera_properties(fp_camera, shadow_fp)
	_copy_camera_properties(td_camera, shadow_td)

func _copy_camera_properties(source: Camera3D, target: Camera3D):
	target.fov = source.fov
	target.near = source.near
	target.far = source.far
	target.cull_mask = source.cull_mask

func _update_cameras():
	_update_camera_shadow(shadow_fp, fp_camera)
	_update_camera_shadow(shadow_td, td_camera)

	td_camera.global_position = Vector3(
		global_position.x, 
		global_position.y + 8, 
		global_position.z
	)

func _update_camera_shadow(shadow: Camera3D, source_camera: Camera3D):
	if shadow and source_camera:
		shadow.global_transform = source_camera.global_transform

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_position = cross_hair.global_position + event.relative * MOUSE_SENS
		new_position.x = clamp(new_position.x, 0, screen_size.x)
		new_position.y = clamp(new_position.y, 0, viewport_fp.size.y)
		cross_hair.global_position = new_position 
		
	if event.is_action_pressed("rotate_left"):  # Клавиша Q
		rotate_left = true
	elif event.is_action_released("rotate_left"):
		rotate_left = false
	
	if event.is_action_pressed("rotate_right"):  # Клавиша E
		rotate_right = true
	elif event.is_action_released("rotate_right"):
		rotate_right = false
		


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		_shoot()
		
	if rotate_left and !rotate_right:
		rotation.y += CAMERA_SENS * delta
	elif rotate_right and !rotate_left:
		rotation.y -= CAMERA_SENS * delta

func _shoot() -> void:
	pass

func _physics_process(delta: float) -> void:
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
	
	_update_cameras()
	move_and_slide()
