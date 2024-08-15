extends CharacterBody2D

signal hit()
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var db = db_manager.new()
var stat : Dictionary
var health
var attack
var mob_attack = 1
var direction = 0
var is_attacking = false
var momentum
var is_on_campfire = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$StateChart.set_expression_property("spike_touched",false)
	$StateChart.set_expression_property("animation_finished",false)
	stat = db.get_item_from_player_table("barn")
	health = stat.get("health")
	#attack = stat.get("attack")
	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor() && !is_attacking:
		velocity.y += gravity * delta
	
	$StateChart.set_expression_property("key_pressed",is_bind_key_pressed())
	$StateChart.set_expression_property("is_on_floor",is_on_floor())
	
	if velocity.y > 0:
		$StateChart.send_event("fall")
	
	if velocity.x != 0 && is_on_floor():
		$StateChart.send_event("walk")
	
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
		
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("look_up"):
			flip_animation("top_attack")
			$StateChart.send_event("top_attack")
		else:
			flip_animation("atk_neutral_01")
			$StateChart.send_event("neutral_attack")

	move_and_slide()

func set_velocity_x(vel_x):
	velocity.x = vel_x
	
func is_bind_key_pressed():
	if Input.is_action_pressed("attack") || Input.is_action_pressed("crouch") || Input.is_action_pressed("Jump") || Input.is_action_pressed("look_up") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		return true
		
func flip_animation(animation_name):
	var atk_animation = $AnimationPlayer.get_animation(animation_name)
	var offset_track_idx = atk_animation.find_track("Sprite2D:offset",atk_animation.TYPE_VALUE)
	negate_key_value(offset_track_idx,atk_animation)
	
	var collision_shape_track_idx = atk_animation.find_track("CollisionShape2D:position",atk_animation.TYPE_VALUE)
	if collision_shape_track_idx != -1:
		negate_key_value(collision_shape_track_idx,atk_animation)
	var hitbox_track_idx = atk_animation.find_track("Hitbox:position",atk_animation.TYPE_VALUE)
	if hitbox_track_idx != -1:
		negate_key_value(hitbox_track_idx,atk_animation)
	var hitbox_ruban_track_idx = atk_animation.find_track("hitbox_ruban:position",atk_animation.TYPE_VALUE)
	if hitbox_ruban_track_idx != -1:
		negate_key_value(hitbox_ruban_track_idx,atk_animation)
	
func negate_key_value(track_idx,animation):
	var nb_key_track = animation.track_get_key_count(track_idx)
	for idx in nb_key_track:
		var key_value = animation.track_get_key_value(track_idx,idx)
		if $Sprite2D.flip_h && key_value.x > 0:
			key_value.x = - key_value.x
		elif (!$Sprite2D.flip_h) && key_value.x < 0:
			key_value.x = - key_value.x
		animation.track_set_key_value(track_idx,idx,key_value)
	
func move():
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func jump():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$StateChart.send_event("jump")

func _input(event):
	if event.is_action_pressed("crouch"):
		if is_on_campfire:
			$StateChart.send_event("rest")
		else:
			$StateChart.send_event("crouch")
	if event.is_action_pressed("look_up"):
		if is_on_campfire:
			$StateChart.send_event("idle")

func _on_idle_state_physics_processing(_delta):
	move()
	jump()

func _on_walk_state_physics_processing(_delta):
	move()
	jump()

func _on_animation_player_animation_finished(animation_name):
	match animation_name:
		"death":
			get_tree().call_deferred("reload_current_scene")
		"atk_neutral_01","top_attack":
			is_attacking = false
			$StateChart.send_event("end_attack")
		"roll":
			$StateChart.send_event("end_roll")
		"hit":
			$StateChart.send_event("end_hit")
		"air_attack","air_attack_top","air_attack_down":
			is_attacking = false
			$StateChart.send_event("end_air_attack")


func _on_hitbox_area_entered(area):
	if area.is_in_group("spike"):
		$StateChart.set_expression_property("spike_touched",true)
		health = 1
		$StateChart.send_event("hit")
	
	if area.is_in_group("campfire"):
		print("campfire")
		is_on_campfire = true
	
	if area.is_in_group("projectile"):
		mob_attack = 3
		$StateChart.send_event("hit")
		
func _on_hitbox_area_exited(area):
	if area.is_in_group("campfire"):
		is_on_campfire = false
			
func _on_hitbox_body_entered(body):
	if body.is_in_group("mob"):
		mob_attack = db.get_item_from_mob_table(body.name).get("attack")
		print("hit")
		$StateChart.send_event("hit")

func _on_hit_state_entered():
	velocity.x = 0
	#print("mob_attack ",mob_attack)
	health -= mob_attack
	hit.emit()
	#print("health ",health)
	if(health <= 0):
		$StateChart.send_event("death")

func detect_air_attack_input():
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		if Input.is_action_pressed("look_up"):
			flip_animation("air_attack_top")
			$StateChart.send_event("air_attack_top")
		elif Input.is_action_pressed("crouch"):
			flip_animation("air_attack_down")
			$StateChart.send_event("air_attack_down")
		else:
			flip_animation("air_attack")
			$StateChart.send_event("air_attack")

func _on_jump_state_physics_processing(_delta):
	move()
	detect_air_attack_input()

func _on_fall_state_physics_processing(_delta):
	move()
	detect_air_attack_input()

func _on_roll_state_entered():
	if $Sprite2D.flip_h:
		velocity.x = -SPEED
	else:
		velocity.x = SPEED

func _on_atk_neutral_01_state_physics_processing(delta):
	move()

func _on_attack_state_entered():
	momentum = velocity
	velocity = Vector2(0,0)

func _on_attack_state_exited():
	velocity = momentum
