@tool
extends ColorRect
@export var ingame_zoom : float = 1
@export var test = false

func _ready(): 
	if not Engine.is_editor_hint() and test :
		ingame_zoom = 0.5
		zoom_test(0)

func _process(delta):
	$FeedGrabber.global_position = ingame_zoom * ($PixelArt.size/2.0)
	$Frame.global_position = ingame_zoom * ($PixelArt.size/2.0) - $Frame.size/2.0
	size.y = ProjectSettings.get("display/window/size/viewport_height")
	size.x = ProjectSettings.get("display/window/size/viewport_width")
	scale = Vector2.ONE
	global_position = Vector2.ZERO
	rotation = 0
	#if abs(ingame_zoom) < 0.5 :
		#ingame_zoom = 0.5 * sign(ingame_zoom)
	
	$PixelArt.subprocess(delta)

func zoom_test(phase=0) :
	var zoom = create_tween()
	if phase == 0 :
		zoom.tween_property(self,"ingame_zoom",4,4.0)
		zoom.tween_callback(zoom_test.bind(1))
	if phase == 1 :
		zoom.tween_property(self,"ingame_zoom",0.5,4.0)
		zoom.tween_callback(zoom_test.bind(0))
