extends CharacterBody2D

##TO DO LIST :
	#Blood and death animation
	#Animations
	#Discovery cutscene*

var health : float = 100
var hit_tween : Tween = null

func _ready():
	pass


func _process(delta):
	pass


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
