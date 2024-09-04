extends CharacterBody2D

const SPEED = 100.0
@onready var navigation_agent = $NavigationAgent2D
@export var target_to_chase : CharacterBody2D
@export var projectile_scene : PackedScene
var db = db_manager.new()
var stat : Dictionary
var health
var barn_attack
var knockback = Vector2.ZERO

var cooldown_timeout = false
var in_attack_area = false
var in_viewing_area = false
var attack_animation_running = false
var player_body

func _ready():
	set_physics_process(false)
	call_deferred("wait_for_physics")
	$AttackTimer.start(2.0)
	stat = db.get_item_from_mob_table("flyingMob")
	health = stat.get("health")
	barn_attack = db.get_item_from_player_table("barn").get("attack")

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

func _on_walk_state_physics_processing(_delta):
	move()
	
func _on_walk_state_entered():
	if !attack_animation_running:
		$AnimationPlayer.play("flyingMob/idle")

func _on_recul_state_physics_processing(_delta):
	navigation_agent.target_position = target_to_chase.global_position
	move_and_slide()
	
func _on_recul_state_entered():
	velocity = global_position.direction_to(navigation_agent.get_next_path_position()).rotated(deg_to_rad(180)) * (SPEED/2)

func _on_idle_state_physics_processing(_delta):
	if !attack_animation_running:
		$AnimationPlayer.play("flyingMob/idle")
		
	if(player_body.velocity != Vector2.ZERO && in_viewing_area):
		$StateChart.send_event("recul")

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
		in_viewing_area = true
		player_body = body
		#print("enter viewing area")
		if(body.velocity != Vector2.ZERO):
			#print("body.velocity != Vector2.ZERO")
			$StateChart.send_event("recul")
			#print("state recul")
		else:
			#print("body.velocity == Vector2.ZERO")
			$StateChart.send_event("idle")
			#print("state idle")

func _on_viewing_area_body_exited(body):
	if body.is_in_group("player"):
		in_viewing_area = false
		#print("exit viewing area")
		$StateChart.send_event("walk")
		

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"flyingMob/attack":
			$AttackTimer.start(3.0)
			cooldown_timeout = false
			attack_animation_running = false
		"flyingMob/death":
			queue_free()

func _on_animation_player_animation_started(anim_name):
	match anim_name:
		"flyingMob/attack":
			attack_animation_running = true

func _on_hitbox_area_entered(area):
	if area.is_in_group("hitbox_ruban"):
		$StateChart.send_event("hit")

func _on_hit_state_entered():
	health -= barn_attack
	if(health <= 0):
		$StateChart.send_event("death")

func _on_hit_state_physics_processing(delta):
	knockback = knockback.move_toward(Vector2.ZERO,1)
	velocity += knockback*delta
	#print("velocity ",velocity)
	#print("global_position before velocity",global_position)
	global_position += velocity
	#print("global_position after velocity",global_position)
