extends CharacterBody2D

##TO DO LIST :
	#Blood and death animation
	#Animations
	#Discovery cutscene
	#Frost wave dispawn
	#Pause après attaques dans range grande ou petite
	#Stomping anim
	#Knpckback against wall bug

enum s {IDLE,FLIP,BRUTAL,BRUTAL_BACK,DASH_LOAD,DASH,SMALL_BACK,FROST,JUMP,WAIT,DASH_WARN_LOAD}
var state : int = s.IDLE
var state_time = 0

@export var player : CharacterBody2D = null
var player_in_small_range : bool
var player_in_big_range : bool

var direction : int = -1
var hit_tween : Tween = null

var health : float = 100
var attacks_progression : int = 0
const progression_goal_range : Array = [7,9]
var progression_goal : int = progression_goal_range[0]

const flip_length : float = 0.4

const brutal_length : float = 1.0
const brutal_hit_start : float = 0.75
const brutal_hit_duration : float = 0.15
const brutal_max_combo : int = 4
var chained_brutals : int = 0

var dash_velocity : float = 0.0
const dash_load_length : float = 0.3
const dash_warn_load_length : float = 0.6
const dash_speed : float = 600
const dash_length : float = 1.2
const dash_deceleration : float = 800

const small_back_length : float = 0.3

const frost_length : float = 1.5
const frost_speed : float = 400
const frost_max_combo : int = 4
var frost_wave : PackedScene = preload("res://Igris/frost_wave.tscn")
var chained_frost_waves : int = 0

const jump_length : float = 2.0
const jump_cooldown : float = 1.0
const jump_height : float = 240
var jump_x : Tween = null
var jump_y : Tween = null
var jump_pos : Vector2 = Vector2.ZERO

const wait_time_range : Array = [2.5,3.5]
var wait_time : float = 0


func _ready():
	if not player :
		queue_free()
	change_pause_goal()


func change_pause_goal() :
	progression_goal = randi_range(progression_goal_range[0],progression_goal_range[1])


func _physics_process(delta):
	velocity = Vector2.ZERO
	
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
	$Attacks/Dash.disabled = not (state == s.DASH)
	$Attacks/SmallBack.disabled = not (state == s.SMALL_BACK) 
	
	if get_collision_layer_value(5) == false :
		if not $Hitbox.get_overlapping_bodies().has(player) :
			set_collision_layer_value(5,true)
	if not state == s.JUMP :
		set_collision_mask_value(2,true)
	else :
		set_collision_mask_value(2,false)
		set_collision_layer_value(5,false)
		move_and_collide(jump_pos - global_position)
	
	if state != s.FROST and state != s.IDLE :
		chained_frost_waves = 0
	
	if state != s.BRUTAL and state != s.BRUTAL_BACK and state != s.IDLE :
		chained_brutals = 0
	
	if state == s.DASH or state == s.IDLE or state == s.DASH_LOAD or state == s.SMALL_BACK :
		dash_velocity = clamp(dash_velocity - delta * dash_deceleration,0,INF)
	else :
		dash_velocity = 0
	
	velocity.x += direction * dash_velocity
	
	for attack_box in $Attacks.get_children() :
		attack_box.position.x = abs(attack_box.position.x) * direction
		if attack_box.name.contains("Back") :
			attack_box.position.x *= -1
	
	if not state == s.JUMP :
		move_and_slide()
	
	position.x = clamp(position.x,808+32*3,1616-32*3)

func _transitions() -> s :
	if attacks_progression >= progression_goal :
		change_pause_goal()
		attacks_progression = 0
		wait_time = randi_range(wait_time_range[0],wait_time_range[1])
		return s.WAIT
	
	if state == s.WAIT and state_time >= wait_time :
		return s.IDLE
	
	if not player_in_small_range and not _facing_player() and state == s.IDLE :
		direction = -1 * direction
		return s.FLIP
	
	if state == s.FLIP and state_time >= flip_length :
		return s.IDLE
	
	if state == s.IDLE and player_in_small_range :
		if chained_brutals >= brutal_max_combo :
			return s.DASH_WARN_LOAD
		elif _facing_player() :
			attacks_progression += 1
			chained_brutals += 1
			return s.BRUTAL
		else :
			attacks_progression += 1
			chained_brutals += 1
			return s.BRUTAL_BACK
	
	if state == s.BRUTAL or state == s.BRUTAL_BACK :
		if state_time >= brutal_length :
			return s.IDLE
	
	if player_in_big_range and state == s.IDLE :
		return s.DASH_LOAD
	
	if state == s.DASH_LOAD and state_time >= dash_load_length :
		dash_velocity = dash_speed
		attacks_progression += 1
		return s.DASH
	
	if state == s.DASH_WARN_LOAD and state_time >= dash_warn_load_length :
		dash_velocity = dash_speed
		attacks_progression += 1
		return s.DASH
	
	if state == s.DASH and (state_time >= dash_length or is_on_wall()) :
		if player_in_small_range and not _facing_player() :
			return s.SMALL_BACK
		else :
			return s.IDLE
	
	if state == s.SMALL_BACK and state_time >= small_back_length :
		return s.IDLE
	
	if state == s.IDLE and not player_in_big_range and not player_in_small_range :
		var random = randi_range(-1,1)
		if chained_frost_waves >= frost_max_combo :
			random = 2
		if random <= 0 :
			var new_wave = frost_wave.instantiate()
			new_wave.direction = direction
			new_wave.max_speed = frost_speed
			new_wave.boss = self
			new_wave.global_position = global_position
			get_parent().add_child(new_wave)
			chained_frost_waves += 1
			return s.FROST
		else :
			jump_pos = global_position
			jump_x = create_tween()
			jump_x.tween_property(self,"jump_pos:x",player.global_position.x,jump_length-jump_cooldown)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			jump_y = create_tween()
			jump_y.tween_property(self,"jump_pos:y",global_position.y - jump_height,(jump_length-jump_cooldown)/2)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			jump_y.chain().tween_property(self,"jump_pos:y",get_parent().to_global(Vector2(0,344)).y,(jump_length-jump_cooldown)/2)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			return s.JUMP
	
	if state == s.FROST and state_time >= frost_length :
		return s.IDLE
	
	if state == s.JUMP and state_time >= jump_length :
		return s.IDLE
	
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
