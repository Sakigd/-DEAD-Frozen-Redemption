extends CharacterBody2D

const SPEED = 100.0
@onready var navigation_agent = $NavigationAgent2D
@export var target_to_chase : CharacterBody2D
@export var projectile_scene : PackedScene
var cooldown_timeout = false
var in_attack_area = false
var attack_animation_running = false

func _ready():
	set_physics_process(false)
	call_deferred("wait_for_physics")
	$AttackTimer.start(2.0)

func wait_for_physics():
	await get_tree().physics_frame
	set_physics_process(true)

func create_projectile():
	var projectile = projectile_scene.instantiate()
	owner.add_child(projectile)
	projectile.global_position = $ProjectileSpawn.global_position
	var angle = global_position.direction_to(navigation_agent.get_next_path_position()).angle()
	projectile.transform = Transform2D(angle,projectile.global_position)
	
func move():
	navigation_agent.target_position = target_to_chase.global_position
	velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * SPEED
	#print("idle",velocity)
	move_and_slide()

func _on_idle_state_physics_processing(_delta):
	move()
	
func _on_idle_state_entered():
	if !attack_animation_running:
		$AnimationPlayer.play("flyingMob/idle")

func _on_recul_state_physics_processing(delta):
	navigation_agent.target_position = target_to_chase.global_position
	move_and_slide()
	
func _on_recul_state_entered():
	velocity = global_position.direction_to(navigation_agent.get_next_path_position()).rotated(deg_to_rad(180)) * SPEED

func _on_attack_state_physics_processing(_delta):
	#if $AttackTimer.time_left == 0 :
		#$AttackTimer.start(3.0)
	pass

func _on_attack_timer_timeout():
	cooldown_timeout = true
	if in_attack_area:
		$AnimationPlayer.play("flyingMob/attack")
	
func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		in_attack_area = true
		if cooldown_timeout:
			$AnimationPlayer.play("flyingMob/attack")
		
func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		in_attack_area = false

func _on_viewing_area_body_entered(body):
	if body.is_in_group("player"):
		$StateChart.send_event("recul")

func _on_viewing_area_body_exited(body):
	if body.is_in_group("player"):
		$StateChart.send_event("idle")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"flyingMob/attack":
			$AttackTimer.start(3.0)
			cooldown_timeout = false
			attack_animation_running = false

func _on_animation_player_animation_started(anim_name):
	match anim_name:
		"flyingMob/attack":
			attack_animation_running = true
			
