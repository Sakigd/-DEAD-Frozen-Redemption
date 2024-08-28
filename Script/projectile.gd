extends Area2D

var speed = 250
# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	translate(transform.x*speed*delta)

func _on_body_entered(_body):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
