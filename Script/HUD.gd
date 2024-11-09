extends CanvasLayer
@onready var player := $"../../../PixelArt/PixelArtViewport/Game/Player"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"HudFrozenAshes/cendre_gelée".text = str(player.cendre_gelee)
	$HudProfile/health_bar.set_value_no_signal(player.health)
	match player.nbr_potion:
		3:
			$HudProfile/potion1.set_pressed_no_signal(true)
			$HudProfile/potion2.set_pressed_no_signal(true)
			$HudProfile/potion3.set_pressed_no_signal(true)
		2:
			$HudProfile/potion1.set_pressed_no_signal(true)
			$HudProfile/potion2.set_pressed_no_signal(true)
			$HudProfile/potion3.set_pressed_no_signal(false)
		1:
			$HudProfile/potion1.set_pressed_no_signal(true)
			$HudProfile/potion2.set_pressed_no_signal(false)
			$HudProfile/potion3.set_pressed_no_signal(false)
		0:
			$HudProfile/potion1.set_pressed_no_signal(false)
			$HudProfile/potion2.set_pressed_no_signal(false)
			$HudProfile/potion3.set_pressed_no_signal(false)
