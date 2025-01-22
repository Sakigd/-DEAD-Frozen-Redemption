extends CharacterBody2D

var direction = -1
var speed = 0
var max_speed = 100
var boss = null

func _ready():
	speed = max_speed * 0.4
	if direction == 1 :
		scale.x = -1
	var acceleration = create_tween()
	acceleration.tween_property(self,"speed",max_speed,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func _process(_delta):
	if not boss or not is_instance_valid(boss) :
		queue_free()
	velocity.x = direction * speed
	if is_on_wall() :
		queue_free()
	move_and_slide()
