@tool
class_name Game
extends ColorRect

@export var ingame_zoom : float = 1.0
@export var test = false
#const SaveManager = preload("res://GameCore/SaveManager.gd")
const SAVE_PATH = "user://example_save_data.sav"
var player : CharacterBody2D
var PlayerCamera : Camera2D
var map: Node2D
## Emitted when [method load_room] has loaded a room. You can use it when you want to call some methods after loading a room (e.g. positioning the player).
signal room_loaded

func _ready(): 
	if not Engine.is_editor_hint() and test :
		ingame_zoom = 0.5
		zoom_test(0)
	
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton",self)
	
	map = $PixelArt/PixelArtViewport.get_child(0)
	#print(map.get_path())
	player = map.find_child("Player")
	#print(player.get_path())
	PlayerCamera = $PlayerCamera
	init_room()

func _process(delta):
	$FeedGrabber.global_position = ingame_zoom * ($PixelArt.size/2.0)
	$Frame.global_position = ingame_zoom * ($PixelArt.size/2.0) - $Frame.size/2.0
	size.y = ProjectSettings.get("display/window/size/viewport_height")
	size.x = ProjectSettings.get("display/window/size/viewport_width")
	scale = Vector2.ONE
	global_position = Vector2.ZERO
	rotation = 0
	if PlayerCamera != null && player != null:
		PlayerCamera.position = player.position
	#print(get_tree_string())
	#if abs(ingame_zoom) < 0.5 :
		#ingame_zoom = 0.5 * sign(ingame_zoom)
	
	$PixelArt.subprocess(delta)

## Loads a map and adds as a child of this node. If a map already exists, it will be removed before the new one is loaded. This method is asynchronous, so you should call it with [code]await[/code] if you want to do something after the map is loaded. Alternatively, you can use [signal room_loaded].
func load_room(path: String, parent_node = $PixelArt/PixelArtViewport):
	player = null
	
	if not path.is_absolute_path():
		path = "res://Scene/Levels/"+path
	
	if map:
		print("map before load_room ",map.get_path())
		map.queue_free()
		await map.tree_exited
		map = null
	
	map = load(path).instantiate()
	parent_node.add_child(map)
	map.owner = parent_node
	print("map after load_room ",map.get_path())
	#print(get_tree_string_pretty())
	player = map.find_child("Player")
	print("player in load_room ",player.get_path())
	init_room()

	room_loaded.emit()
	
func init_room():
	var background_size = map.get_node("Background").get_rect().size
	PlayerCamera.limit_bottom = background_size.y
	PlayerCamera.limit_top = 0
	PlayerCamera.limit_left = 0
	PlayerCamera.limit_right = background_size.x

func reset_state():
	pass
	#save_data = null
	#current_room = null

static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

func zoom_test(phase=0) :
	var zoom = create_tween()
	if phase == 0 :
		zoom.tween_property(self,"ingame_zoom",4,4.0)
		zoom.tween_callback(zoom_test.bind(1))
	if phase == 1 :
		zoom.tween_property(self,"ingame_zoom",0.5,4.0)
		zoom.tween_callback(zoom_test.bind(0))
