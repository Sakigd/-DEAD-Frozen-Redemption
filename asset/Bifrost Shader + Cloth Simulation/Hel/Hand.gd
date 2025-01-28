@tool
extends Sprite2D
@export_range(0,1) var pull_strength = 0.05
@export var momentum_strength = 0.0
@export var max_distance = 16.0

func _process(_delta: float) -> void:
	var target = get_node("../../../"+name.replace("Comp",""))
	global_position = get_parent().global_position + position
	#var arm = get_node("../../"+name.replace("HandComp","ArmSkeleton"))
	#arm.global_position = get_parent().global_position + arm.position
	get_parent().global_position = Vector2.ZERO
	var initial_pos = global_position
	var pull_vec = global_position.direction_to(target.global_position) * global_position.distance_to(target.global_position) * pull_strength
	global_position.x += snapped(pull_vec.x,0.01)
	global_position.y += snapped(pull_vec.y,0.01)
	var velocity = global_position - initial_pos
	global_position += velocity
	if target.global_position.distance_to(global_position) > max_distance :
		global_position = target.global_position + target.global_position.direction_to(global_position) * max_distance
