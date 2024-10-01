extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"cendre_gelée".text = str($"../Player".cendre_gelee)
	$health_bar.set_value_no_signal($"../Player".health)
	match $"../Player".nbr_potion:
		3:
			$potion1.set_pressed_no_signal(true)
			$potion2.set_pressed_no_signal(true)
			$potion3.set_pressed_no_signal(true)
		2:
			$potion1.set_pressed_no_signal(true)
			$potion2.set_pressed_no_signal(true)
			$potion3.set_pressed_no_signal(false)
		1:
			$potion1.set_pressed_no_signal(true)
			$potion2.set_pressed_no_signal(false)
			$potion3.set_pressed_no_signal(false)
		0:
			$potion1.set_pressed_no_signal(false)
			$potion2.set_pressed_no_signal(false)
			$potion3.set_pressed_no_signal(false)
