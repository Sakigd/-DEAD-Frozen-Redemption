extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#$health_bar.set_value_no_signal(player.health)


func _on_player_hit():
	$health_bar.set_value_no_signal($"../Player".health)
