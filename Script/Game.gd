extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://example_save_data.sav"

# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String

var generated_rooms: Array[Vector3i]

# Called when the node enters the scene tree for the first time.
func _ready():
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton",self)
	# Make sure MetSys is in initial state.
	MetSys.reset_state()
	# Assign player for MetSysGame.
	set_player($Player)
	
	if FileAccess.file_exists(SAVE_PATH):
		# If save data exists, load it using MetSys SaveManager.
		var save_manager := SaveManager.new()
		save_manager.load_from_text(SAVE_PATH)
		# Assign loaded values.
		#collectibles = save_manager.get_value("collectible_count")
		#generated_rooms.assign(save_manager.get_value("generated_rooms"))
		#events.assign(save_manager.get_value("events"))
		#player.abilities.assign(save_manager.get_value("abilities"))
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
		
	# Initialize room when it changes.
	room_loaded.connect(init_room,CONNECT_DEFERRED)
	# Load the starting room.
	load_room(starting_map)
	
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(^"Campfire")
	if start:
		player.position = start.position
	
	# Reset position tracking (feature specific to this project).
	#reset_map_starting_coords.call_deferred()
	# Add module for room transitions.
	add_module("RoomTransitions.gd")

# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

# Save game using MetSys SaveManager.
func save_game():
	var save_manager := SaveManager.new()
	#save_manager.set_value("generated_rooms", generated_rooms)
	#save_manager.set_value("current_room", MetSys.get_current_room_name())
	#save_manager.set_value("player_hp", player.health)
	#save_manager.set_value("cendres_gelée", )
	#save_manager.set_value("capacité (rune)", )
	#save_manager.set_value("player_stat", )
	#save_manager.set_value("player_lvl", )	
	#save_manager.set_value("boss_vaincue", )
	#save_manager.set_value("arbre de compétence", )
	save_manager.save_as_text(SAVE_PATH)

#func reset_map_starting_coords():
	#$UI/MapWindow.reset_starting_coords()

func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	player.on_enter()	
