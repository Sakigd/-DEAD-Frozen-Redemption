extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var db = db_manager.new()
var stat
var health
var attack
var cendre_gelee

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	stat = db.get_item_from_mob_table("igris")
	health = stat.health
	cendre_gelee = stat.cendre_gelee

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_hitbox_area_entered(area):
	if area.is_in_group("hitbox_ruban"):
		$StateChart.send_event("hit")

func _on_hit_state_entered():
	health -= db.get_item_from_player_table("player").attack
	print("igris health ",health)
	var tween =  get_tree().create_tween()
	tween.tween_property($Sprite2D,"modulate",Color.BLACK,0.1)
	tween.tween_property($Sprite2D,"modulate",Color.WHITE,0.1)
	#print("mob health ",health)
	#print("barn attack ",db.get_item_from_player_table("barn").get("attack"))
	if (health <= 0):
		$StateChart.send_event("death")
	else :
		$StateChart.send_event("idle")

#func _on_animation_player_animation_finished(anim_name):
	#match anim_name:
		#"hit":
			#$StateChart.send_event("idle")
		#"death":
			#death()

func _on_death_state_entered():
	death()

func death():
	queue_free()
