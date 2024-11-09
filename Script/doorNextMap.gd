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
	print("map in move_to_door ",map.get_path())
	# Get the door node.
	var door = map.get_node(^"doorNextMap")
	var end_door : Vector2 = door.get_child(0).shape.get_rect().end
	# Move the player to door.
	var player = Game.get_singleton().player
	print("player in move_to_door ",player.get_path())
	var player_size = player.find_child("CollisionShape2D").shape.get_rect().size
	var door_size = door.get_child(0).shape.get_rect().size
	if(player.is_flip_h()):
		player.position = door.position + Vector2(end_door.x-door_size.x-player_size.x/2-5,end_door.y-player_size.y/2)
	else:
		player.position = door.position + Vector2(end_door.x+player_size.x/2+5,end_door.y-player_size.y/2)	
	
	print("door.position ", door.position)
	print("end_door ", end_door)
	print("door size ",door.get_child(0).shape.get_rect().size)
	print("player size ",player.find_child("CollisionShape2D").shape.get_rect().size)
	print("end door + player_size.y/2 ",Vector2(end_door.x,end_door.y-player_size.y/2)) 
	print("player.position ",player.position)
	# Disable player's "event". It's delayed to prevent re-entering the door.
	map.get_tree().create_timer(0.1).timeout.connect(func():
		Game.get_singleton().player.event = false)
