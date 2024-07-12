extends CharacterBody2D

signal hit()
const SPEED = 200.0
const JUMP_VELOCITY = -420.0

var db = db_manager.new()
var stat : Dictionary
var health
var attack
var mob_attack = 1
var direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$StateChart.set_expression_property("spike_touched",false)
	$StateChart.set_expression_property("animation_finished",false)
	stat = db.get_item_from_player_table("barn")
	health = stat.get("health")
	attack = stat.get("attack")
	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	$StateChart.set_expression_property("key_pressed",Input.is_anything_pressed())
	$StateChart.set_expression_property("is_on_floor",is_on_floor())
	
	if velocity.y > 0 :
		$StateChart.send_event("fall")
	
	if velocity.x != 0 && is_on_floor():
		$StateChart.send_event("walk")
	
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
		
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("look_up"):
			$StateChart.send_event("top_attack")
		else:
			$StateChart.send_event("neutral_attack")

	move_and_slide()	

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
		$StateChart.send_event("crouch")

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
			$StateChart.send_event("end_attack")
		"roll":
			$StateChart.send_event("end_roll")
		"hit":
			$StateChart.send_event("end_hit")


func _on_hitbox_area_entered(area):
	if area.is_in_group("spike"):
		$StateChart.set_expression_property("spike_touched",true)
		health = 1
		$StateChart.send_event("hit")
	
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


func _on_jump_state_physics_processing(_delta):
	move()
	if Input.is_action_just_pressed("attack"):
		$StateChart.send_event("air_attack")

func _on_fall_state_physics_processing(_delta):
	move()
	if Input.is_action_just_pressed("attack"):
		$StateChart.send_event("air_attack")

func _on_roll_state_physics_processing(_delta):
	if Input.is_action_pressed("move_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("move_right"):
		velocity.x = SPEED
	else:
		velocity.x = SPEED
	
