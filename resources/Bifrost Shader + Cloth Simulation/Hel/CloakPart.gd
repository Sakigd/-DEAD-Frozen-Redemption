@tool
extends Line2D
@export_category("Position")
@export var target : Node2D
@export var offset : Vector2
@export_category("Setup")
@export var segments = 7
@export var segment_length = 16
@export var min_angle = 90
@export_category("Physics")
@export var inertia = 0.5
@export var dampening = 0.5
@export var transfer = 0.75
@export_category("Oscillation")
@export var natural_direction = 0.0
@export var resistance = 1.0
@export_range(-1,1) var oscillation_strength = 0.5
@export var oscillation_speed = 4.0
var velocities = []
@export var record_position = true

func _ready():
	velocities = []
	for x in range(segments) : 
		velocities.append(Vector2.ZERO)

var time = 0.0
func _process(delta):
	get_parent().global_position = Vector2.ZERO
	
	if record_position == false and Engine.is_editor_hint() :
		return
	
	time += delta * oscillation_speed
	
	if not points.size() == segments :
		points = []
		velocities = []
		for x in range(segments) : 
			add_point(Vector2.ZERO)
			velocities.append(Vector2.ZERO)
	
	for point in range(points.size()) :
		if point == 0 :
			set_point_position(0,to_local(target.global_position+offset))
			continue
		
		var verylast = null
		if point >= 2 :
			verylast = points[point-2]
		var last = points[point-1]
		var current = points[point]
		var angle = null
		
		#velocities[point] += Vector2.from_angle(last.direction_to(current).angle()-deg_to_rad(90))*sin(point/2)*sin(wind/10)*0.1
		if point != points.size()-1 :
			current += velocities[point]*inertia#*(1-(point+1)/points.size())
			current += velocities[point+1]*inertia*0.5
		
		if last.distance_to(current) != segment_length :
			
			var newpos : Vector2
			if current != last :
				newpos = last.direction_to(current) * segment_length
				velocities[point] += (current.direction_to(last+newpos) * current.distance_to(last+newpos)) * (((point+1)/points.size())*transfer+1-transfer)
			else :
				newpos = Vector2(1,0).normalized() * segment_length
			
			current = last+newpos
			
			if verylast :
				var LV = verylast - last
				var LC = current - last
				angle = rad_to_deg(acos(  (LV.dot(LC)) / (LV.length() * LC.length())  ))
			 
			if angle and angle < min_angle :
				print("close at point ",point)
		
		if last :
			velocities[point] = velocities[point].normalized() * velocities[point].length()*dampening
		var natural_direction_vec = Vector2.from_angle(deg_to_rad(natural_direction-90))
		if point == 1 :
			velocities[point] += Vector2.from_angle(natural_direction_vec.angle()+sin(time)*deg_to_rad(oscillation_strength*180)) * natural_direction_vec.length()
		velocities[point] += natural_direction_vec.normalized() * resistance
		
		set_point_position(point,current)
