@tool
extends SubViewportContainer
@onready var Screen = get_node("../")


#func _ready(): 
	#if Engine.is_editor_hint() :
		#return
	#var Scene = load("res://Scene/game.tscn").instantiate()
	#$PixelArtViewport.add_child(Scene)
	#Scene.global_position = Vector2.ZERO

#func _process(delta) :
	#if Engine.is_editor_hint()  :
		#subprocess(delta)

func subprocess(_delta):
	global_position = Vector2.ZERO
	scale = Vector2(Screen.ingame_zoom,Screen.ingame_zoom)
	#if not Engine.is_editor_hint() :
		#print_rich("\n[b]Pixelart Viewport global_position : [color=cyan]", global_position)
		#if global_position != Vector2.ZERO : print_rich("[color=red][b]I hate my life.")
	
	$PixelFrame/PixelFrameOutline.position = Vector2.ZERO-Vector2(8,8)
	$PixelFrame/PixelFrameOutline.size = size+Vector2(8,8)*2
	
	if Engine.is_editor_hint() :
		return
	
	if $PixelArtViewport.get_camera_2d() :
		if $PixelArtViewport.get_camera_2d().zoom.y != 1 :
			get_parent().ingame_zoom = $PixelArtViewport.get_camera_2d().zoom.y
			$PixelArtViewport.get_camera_2d().zoom.y = 1
		if $PixelArtViewport.get_camera_2d().zoom.x != 1 :
			get_parent().ingame_zoom = $PixelArtViewport.get_camera_2d().zoom.x
			$PixelArtViewport.get_camera_2d().zoom.x = 1
