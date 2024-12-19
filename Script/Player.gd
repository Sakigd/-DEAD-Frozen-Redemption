extends CharacterBody2D

signal hit()
const SPEED = 200.0
const JUMP_VELOCITY = -368.0

var db = db_manager.new()
var stat
var health
var max_health
var attack
var cendre_gelee : int
var nbr_potion = 2
var potion_regen = 20
var mob_attack = 1
var direction = 0
var is_attacking = false
#var is_legde_grabbing = false
var momentum
var is_on_campfire = false
var attack_direction = 0
var reset_position : Vector2
var event: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$StateChart.set_expression_property("spike_touched",false)
	$StateChart.set_expression_property("animation_finished",false)
	stat = db.get_item_from_player_table("player")
	health = stat.health
	max_health = stat.health
	on_enter()
	#$RemoteTransform2D.remote_path = $""
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
	
	if($LedgeGrabRaycast.is_colliding()):
		var ledge_grab_collider = $LedgeGrabRaycast.get_collider()
		var ledge_grab_shape_id = $LedgeGrabRaycast.get_collider_shape()
		var ledge_grab_owner_id = ledge_grab_collider.shape_find_owner(ledge_grab_shape_id)
		var ledge_grab_shape = ledge_grab_collider.shape_owner_get_owner(ledge_grab_owner_id)
		var ledge_grab_object_collided = ledge_grab_shape.get_parent()
		#print("ledge_grab_shape parent :",ledge_grab_shape.get_parent())
		#print("ledge_grab_raycast collision point ",$LedgeGrabRaycast.get_collision_point())
		#print("legde_grab_area global position ",$Legde_grab_area.global_position)
		
		if(ledge_grab_object_collided.is_in_group("plateforme")):
			$StateChart.send_event("ledge_grab")
	
	#var target = get_collider() # A CollisionObject2D.
	#var shape_id = get_collider_shape() # The shape index in the collider.
	#var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
	#var shape = target.shape_owner_get_owner(owner_id)


func set_velocity_x(vel_x):
	velocity.x = vel_x
	
func is_bind_key_pressed():
	if Input.is_action_pressed("attack") || Input.is_action_pressed("crouch") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
		return true
	else:
		return false
		
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
		
func is_flip_h():
	if($Sprite2D.flip_h):
		return true
	else:
		return false

func _input(event):
	if event.is_action_pressed("crouch"):
		if is_on_campfire:
			$StateChart.send_event("rest")
			#Game.get_singleton().save_game()
		else:
			$StateChart.send_event("crouch")
	if event.is_action_pressed("look_up"):
		if is_on_campfire:
			$StateChart.send_event("idle")
	
	if event.is_action_pressed("potion"):
		if(is_on_floor() && health != max_health && nbr_potion>0):
			if(health + potion_regen > max_health):
				health = max_health
			else :
				health += potion_regen
			nbr_potion -= 1

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
		mob_attack = db.get_item_from_mob_table("frozenThrower").attack
		$StateChart.send_event("hit")
		
func _on_hitbox_area_exited(area):
	if area.is_in_group("campfire"):
		is_on_campfire = false
			
func _on_hitbox_body_entered(body):
	if body.is_in_group("mob"):
		mob_attack = db.get_item_from_mob_table("desperatedSlave").attack
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

func _on_ground_attack_state_physics_processing(_delta):
	if attack_direction == 0:
		if !$Sprite2D.flip_h:
			attack_direction = 1
		else:
			attack_direction = -1
	
	if Input.is_action_pressed("move_right"):
		if attack_direction != -1:
			direction = 1
			attack_direction = 1
	
	if Input.is_action_just_released("move_right"):
		direction = 0
	
	if Input.is_action_pressed("move_left"):
		if attack_direction != 1:
			direction = -1
			attack_direction = -1
	
	if Input.is_action_just_released("move_left"):
		direction = 0
	
	velocity.x = direction * SPEED

func _on_ground_attack_state_exited():
	attack_direction = 0

func _on_attack_state_entered():
	#momentum = velocity
	velocity = Vector2(0,0)

func on_enter():
	reset_position = position
#func _on_attack_state_exited():
	#velocity = momentum

func _on_hitbox_ruban_body_entered(body):
	if body.is_in_group("plateforme") || body.is_in_group("mob"):
		$SFX/WhipHit.play()

#func _on_ledge_grab_state_physics_processing(_delta):
	#velocity = Vector2(0,0)

func _on_ledge_grab_state_entered():
	var collision_point = $LedgeGrabRaycast.get_collision_point()
	var player_hand_position = Vector2(5,-23)
	print("player hand global_position ",to_global(player_hand_position))
	print("player position ",position)
	print("raycast collision point - player hand global_position ",collision_point-to_global(player_hand_position))
	print("ledge_grab_raycast collision point ",$LedgeGrabRaycast.get_collision_point())
	global_translate(collision_point-to_global(player_hand_position))
	gravity = 0
	velocity = Vector2(0,0)
	
func _on_ledge_grab_state_exited():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _on_ledge_grab_state_input(event):
	if event.is_action_pressed("look_up"):
		var collision_point = $LedgeGrabRaycast.get_collision_point()
		$Legde_grab_area.global_position = Vector2(collision_point.x,collision_point.y-24)
		#x horizontal, y vertical
