extends Node

@onready var player: CharacterBody3D = get_parent()
@onready var cross_hair: ColorRect = $"../CanvasLayer/CrossHair"
@onready var td_viewport_container: SubViewportContainer = $"../CanvasLayer/TDViewportContainer"
@onready var viewport_td: SubViewport = $"../CanvasLayer/TDViewportContainer/ViewportTD"
@onready var fp_viewport_container: SubViewportContainer = $"../CanvasLayer/FPViewportContainer"
@onready var viewport_fp: SubViewport = $"../CanvasLayer/FPViewportContainer/ViewportFP"
@onready var td_camera: Camera3D = $"../TDCamera"
@onready var fp_camera: Camera3D = $"../FPCamera"

const MOUSE_SENS = 1

var shadow_fp: Camera3D
var shadow_td: Camera3D
var screen_size = Vector2.ZERO

func _ready():
	_setup_split_screen()

func _setup_split_screen():
	# Получаем размер экрана
	screen_size = get_viewport().get_visible_rect().size
	
	# Настраиваем контейнеры для вертикального разделения
	fp_viewport_container.anchors_preset = Control.PRESET_TOP_WIDE
	fp_viewport_container.size = Vector2(screen_size.x, screen_size.y / 2)
	fp_viewport_container.position = Vector2(0, 0)
	
	td_viewport_container.anchors_preset = Control.PRESET_BOTTOM_WIDE
	td_viewport_container.size = Vector2(screen_size.x, screen_size.y / 2)
	td_viewport_container.position = Vector2(0, screen_size.y / 2)
	
	# Настраиваем размеры Viewport'ов
	viewport_fp.size = Vector2(screen_size.x, screen_size.y / 2)
	viewport_td.size = Vector2(screen_size.x, screen_size.y / 2)
	
	# Устанавливаем мировое пространство
	viewport_fp.world_3d = player.get_world_3d()
	viewport_td.world_3d = player.get_world_3d()

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
	target.global_transform = source.global_transform

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_position = cross_hair.global_position + event.relative * MOUSE_SENS
		new_position.x = clamp(new_position.x, 0, fp_viewport_container.size.x)
		new_position.y = clamp(new_position.y, 0, fp_viewport_container.size.y)
		cross_hair.global_position = new_position

func _process(delta: float) -> void:
	_update_cameras()

func _update_cameras():
	_update_camera_shadow_fp(shadow_fp, fp_camera)
	_update_camera_shadow_td(shadow_td, td_camera)

func _update_camera_shadow_fp(shadow: Camera3D, source_camera: Camera3D):
	if shadow and source_camera:
		shadow.global_transform = source_camera.global_transform
		
func _update_camera_shadow_td(shadow: Camera3D, source_camera: Camera3D):
	if shadow and source_camera:
		# TD камера следует за игроком сверху
		var player_pos = player.get_player_position()
		shadow.global_position = Vector3(player_pos.x, player_pos.y + 8, player_pos.z)
		source_camera.global_position = Vector3(player_pos.x, player_pos.y + 8, player_pos.z)
