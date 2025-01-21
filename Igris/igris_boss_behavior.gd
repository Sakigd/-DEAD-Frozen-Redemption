extends CharacterBody2D

##TO DO LIST :
	#Blood and death animation
	#Animations
	#Discovery cutscene*

@export var player : CharacterBody2D = null
var health : float = 100
var hit_tween : Tween = null
var direction : int = -1
enum s {IDLE,FLIP,BRUTAL,BRUTAL_BACK,DASH}
var state : int = s.IDLE
var state_time = 0
var player_in_small_range : bool
var player_in_big_range : bool
const flip_length : float = 0.4
const brutal_length : float = 1.0
const brutal_hit_start : float = 0.75
const brutal_hit_duration : float = 0.15
const dash_length : float = 1.0


func _ready():
	if not player :
		queue_free()


func _physics_process(delta):
	$Sprite.flip_h = (direction == 1)
	
	player_in_small_range = $SmallRange.get_overlapping_bodies().has(player)
	player_in_big_range = $BigRange.get_overlapping_bodies().has(player)
	if player_in_big_range and player_in_small_range :
		player_in_big_range = false
	
	state_time += delta
	var old_state = state
	state = _transitions()
	if old_state != state :
		state_time = 0
	print("s=",state,"   t=",snapped(state_time,0.001))
	
	$Attacks/Brutal.disabled = not (state == s.BRUTAL and state_time >= brutal_hit_start \
		and state_time <= brutal_hit_start+brutal_hit_duration)
	$Attacks/BrutalBack.disabled = not (state == s.BRUTAL_BACK and state_time >= brutal_hit_start \
		and state_time <= brutal_hit_start+brutal_hit_duration)
	
	for attack_box in $Attacks.get_children() :
		attack_box.position.x = abs(attack_box.position.x) * direction
		if attack_box.name.contains("Back") :
			attack_box.position.x *= -1


func _transitions() -> s :
	if not player_in_small_range and not _facing_player() and state == s.IDLE :
		direction = -1 * direction
		return s.FLIP
	
	if state == s.FLIP and state_time >= flip_length :
		return s.IDLE
	
	if state == s.IDLE and player_in_small_range :
		if _facing_player() :
			return s.BRUTAL
		else :
			return s.BRUTAL_BACK
	
	if state == s.BRUTAL or state == s.BRUTAL_BACK :
		if state_time >= brutal_length :
			return s.IDLE
	
	if player_in_big_range :
		return s.DASH
	
	return state


func _hit(value:float=10) :
	health -= value
	$Sprite.self_modulate.g = 0.6
	$Sprite.self_modulate.b = 0.7
	hit_tween = create_tween()
	hit_tween.parallel().tween_property($Sprite,"self_modulate:g",1.0,0.3)
	hit_tween.parallel().tween_property($Sprite,"self_modulate:b",1.0,0.3)
	if health <= 0 :
		queue_free()


func _on_hitbox_area_entered(area):
	if area.is_in_group("hitbox_ruban"):
		_hit()


func _facing_player() :
	var to_player : float = player.global_position.x - global_position.x
	if to_player == 0 :
		return true
	if sign(to_player) == direction :
		return true
	else :
		return false
