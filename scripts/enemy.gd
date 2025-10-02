extends CharacterBody3D



@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var SPEED : float = 3.0
var is_chasing = false

@export var after_paper : PaperNote

func _physics_process(_delta: float) -> void:
	if not is_chasing:
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
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("get_damage"):
		body.get_damage()
		queue_free()


func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.has_method("get_damage"):
		is_chasing = true
