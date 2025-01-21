extends CharacterBody2D

##TO DO LIST :
	#Blood and death animation
	#Animations
	#Discovery cutscene*

@export var player : Node2D = null
var health : float = 100
var hit_tween : Tween = null
var direction : int = -1

func _ready():
	pass


func _physics_process(delta):
	$Sprite.flip_h = (direction == 1)
	print(_player_in_front())


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


func _player_in_front() :
	var to_player : float = player.global_position.x - global_position.x
	if to_player == 0 :
		return true
	if sign(to_player) == direction :
		return true
	else :
		return false
