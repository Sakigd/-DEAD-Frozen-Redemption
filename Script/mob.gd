extends CharacterBody2D

var speed = 30.0
var db = db_manager.new()
var stat : Dictionary
var health
var attack

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = true
var last_slide_collision = null

func _ready():
	$AnimationPlayer.play("walk")
	stat = db.get_item_from_mob_table("desesperatedSlave")
	health = stat.get("health")
	#attack = stat.get("attack")

func _physics_process(delta):
	last_slide_collision = get_last_slide_collision()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if last_slide_collision != null:
		if !$RayCast2D.is_colliding() && is_on_floor():
			flip()

	if is_on_wall():
		flip()
	
	move_and_slide()
	
func flip():
	facing_right = !facing_right
	
	scale.x = abs(scale.x) * -1
	if(facing_right):
		speed = abs(speed)
	else:
		speed = abs(speed) * -1


func _on_hitbox_area_entered(area):
	if area.is_in_group("hitbox_ruban"):
		$StateChart.send_event("hit")

func _on_hit_state_entered():
	health -= db.get_item_from_player_table("barn").get("attack")
	health = 9
	#print("mob health ",health)
	#print("barn attack ",db.get_item_from_player_table("barn").get("attack"))
	if (health <= 0):
		$StateChart.send_event("death")

func _on_hit_state_physics_processing(_delta):
	velocity.x = 0


func _on_death_state_entered():
	queue_free()


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"hit":
			$StateChart.send_event("idle")


func _on_idle_state_physics_processing(_delta):
	velocity.x = speed
