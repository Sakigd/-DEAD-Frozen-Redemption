extends Area2D

@export var target_map: String

func _on_body_entered(body: Node2D):
	# If player entered and isn't doing an event (event in this case is entering the door).
	if body.is_in_group("player") and not body.event:
		body.event = true
		# Teleport player to the exit door position after the room has changed.
		Game.get_singleton().room_loaded.connect(move_to_door,CONNECT_ONE_SHOT)
		Game.get_singleton().load_room(target_map)

# Needs to be static, because the old door disappears before the new scene is loaded.
static func move_to_door():
	var map := Game.get_singleton().map
	# Get the door node.
	var door = map.get_node(^"doorNextMap")
	# Move the player to door.
	Game.get_singleton().player.position = door.position
	# Disable player's "event". It's delayed to prevent re-entering the door.
	map.get_tree().create_timer(0.1).timeout.connect(func():
		Game.get_singleton().player.event = false)
