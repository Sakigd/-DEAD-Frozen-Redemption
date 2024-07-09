extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -420.0
var health = 30
var direction = 0
var attack = 3 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$StateChart.set_expression_property("spike_touched",false)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.y > 0 :
		$StateChart.send_event("fall")
	
	if is_on_floor() && velocity.x == 0:
		$StateChart.send_event("idle")
	
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


func _on_area_2d_area_entered(area):
	if area.is_in_group("spike"):
		$StateChart.set_expression_property("spike_touched",true)
		health = 1
		$StateChart.send_event("hit")


func _on_hit_state_entered():
	health -= 1
	if(health == 0):
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
	
