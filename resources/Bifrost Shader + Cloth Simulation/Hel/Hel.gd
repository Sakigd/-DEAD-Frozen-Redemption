@tool
extends Node2D
@export_enum("left","right") var direction = 0
@export var flip_trigger = false
var last_direction = direction
var flip_tween = null
var hand_tween = null

func _process(_delta: float) -> void:
	if direction != last_direction :
		flip()
	if flip_trigger :
		flip_trigger = false
		flip()
	last_direction = direction

func flip(duration = 0.8) :
	if flip_tween != null :
		flip_tween.pause()
		flip_tween.custom_step(10000.0)
		flip_tween = null
	if hand_tween != null :
		hand_tween.pause()
		hand_tween.custom_step(10000.0)
		hand_tween = null
	flip_tween = create_tween()
	hand_tween = create_tween()
	
	hand_tween.set_parallel()
	hand_tween.tween_property(
		$LeftHand,"position:y",
		$LeftHand.position.y+60,
		duration/2).set_ease(Tween.EASE_IN)
	hand_tween.set_parallel()
	hand_tween.tween_property(
		$RightHand,"position:y",
		$RightHand.position.y+60,
		duration/2).set_ease(Tween.EASE_IN)
	
	hand_tween.tween_callback(middle_flip).set_delay(duration*0.6)
	
	hand_tween.chain()
	hand_tween.tween_property(
		$LeftHand,"position:y",
		$LeftHand.position.y,
		duration/2).set_ease(Tween.EASE_OUT)
	hand_tween.set_parallel()
	hand_tween.tween_property(
		$RightHand,"position:y",
		$RightHand.position.y,
		duration/2).set_ease(Tween.EASE_OUT)
	
	for hand in [$LeftHand,$RightHand] :
		
		var arm = get_node("BodyComponents/"+hand.name.replace("Hand","ArmSkeleton"))
		
		flip_tween.set_parallel()
		flip_tween.tween_property(
			hand,"position:x",
			arm.position.x + (hand.position.x - arm.position.x) * -1,
			duration).set_trans(Tween.TRANS_CUBIC)
		
		if arm.get_node(hand.name.replace("Hand","")+"Upper"+"/Sprite").self_modulate.v != 1 :
			flip_tween.set_parallel()
			flip_tween.tween_property(
				arm.get_node(hand.name.replace("Hand","")+"Upper"+"/Sprite"),
				"self_modulate:v",1,duration).set_trans(Tween.TRANS_CUBIC)
			
			flip_tween.set_parallel()
			flip_tween.tween_property(
				arm.get_node(hand.name.replace("Hand","")+"Upper"+"/"+hand.name.replace("Hand","")+"Lower/Sprite"),
				"self_modulate:v",1,duration).set_trans(Tween.TRANS_CUBIC)
		
		else :
			flip_tween.set_parallel()
			flip_tween.tween_property(
				arm.get_node(hand.name.replace("Hand","")+"Upper"+"/Sprite"),
				"self_modulate:v",0.7,duration).set_trans(Tween.TRANS_CUBIC)
			
			flip_tween.set_parallel()
			flip_tween.tween_property(
				arm.get_node(hand.name.replace("Hand","")+"Upper"+"/"+hand.name.replace("Hand","")+"Lower/Sprite"),
				"self_modulate:v",0.7,duration).set_trans(Tween.TRANS_CUBIC)

func middle_flip() :
	for arm : Skeleton2D in [$BodyComponents/LeftArmSkeleton,$BodyComponents/RightArmSkeleton] :
		arm.z_index *= -1
		var modif = arm.get_modification_stack().get("modifications/0")
		
		if modif.get("flip_bend_direction") :
			modif.set("flip_bend_direction",false)
		
		else :
			modif.set("flip_bend_direction",true)
