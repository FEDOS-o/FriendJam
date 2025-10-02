extends CharacterBody3D



@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var SPEED : float = 3.0
var is_chasing = false
var is_dead = false
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var after_paper : PaperNote

var player: Player

func _ready() -> void:
	player = get_tree().get_root().find_child("Player", true, false)

func _process(delta: float) -> void:
	look_at_player()
	
func look_at_player():
	var player_pos = player.global_transform.origin

	var look_pos = Vector3(player_pos.x, global_transform.origin.y, player_pos.z)

	animated_sprite_3d.look_at(look_pos, Vector3.UP)

func _physics_process(_delta: float) -> void:
	if not is_chasing or is_dead:
		return
	var current_location = global_transform.origin
	#var next_location = navigation_agent_3d.get_next_location()
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	move_and_slide()

func update_target_location(target_location) -> void:
	navigation_agent_3d.target_position = target_location
	#navigation_agent_3d.set_target_location(target_location)
	
	
func die() ->void:
	if is_dead:
		return
	is_dead = true
	animated_sprite_3d.play("Dead")
	#queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not is_dead and body.has_method("get_damage"):
		body.get_damage()
		die()


func _on_chase_area_body_entered(body: Node3D) -> void:
	if not is_dead and body.has_method("get_damage"):
		is_chasing = true
		animated_sprite_3d.play("Walk")
