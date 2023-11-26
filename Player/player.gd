extends KinematicBody


# Declare member variables here.
const CHAR_SCALE = Vector3(0.3, 0.3, 0.3)
const MAX_SPEED = 4.5
const TURN_SPEED = 40
const J_VEL = 8.5
const A_I_DEACCEL = false
const ACCEL = 14.0
const DEACCEL = 14.0
const AIR_ACCEL_FACTOR = 0.4
const SHARP_TURN = 140

var movement_dir = Vector3()
var linear_velocity = Vector3()
var is_jumping = false

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("AnimationTree").set_active(true)
	pass # Replace with function body.

func _physics_process(delta):

	if self.global_translation.y <= -13:
		self.global_translation = Vector3(1, 0, 1)
		
	linear_velocity += gravity * delta
	
	var move_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	var horizontal_dir = horizontal_velocity.normalized()
	var horizontal_speed = horizontal_velocity.length() 

	
	var vertical_velocity = linear_velocity.y

	
	var cam_basis = get_node("Target/Camera").get_global_transform().basis
	var dir = cam_basis * Vector3(move_vector.x, 0, move_vector.y)

	
	dir.y = 0
	dir = dir.normalized()
	var jump_attempt = Input.is_action_pressed("Jump")
	
	if is_on_floor(): #built in function to check if kin_body is touch the ground
		var sharp_turn = horizontal_speed > 0.1 and rad2deg(acos(dir.dot(horizontal_dir))) > SHARP_TURN
		
		
		if (dir.length() > 0.1) and (not sharp_turn):
			if horizontal_speed > 0.001: #check for significant movement
				horizontal_dir = adjust_facing(horizontal_dir, dir, delta, 1.0 / horizontal_speed * TURN_SPEED, Vector3.UP)
			else:
				horizontal_dir = dir 

			if horizontal_speed < MAX_SPEED: # cap player movement speed
				horizontal_speed += ACCEL * delta #apply acceleration over time
		else:
			horizontal_speed -= DEACCEL * delta
			if horizontal_speed < 0: # do not allow the player to slow to a reverse
				horizontal_speed = 0

		horizontal_velocity = horizontal_dir * horizontal_speed
		
		#Watched the video three times and I still don't know what these do?
		var mesh_xform = get_node("Frame").get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - Vector3.UP * facing_mesh.dot(Vector3.UP)).normalized()
		
		if horizontal_speed > 0:
			facing_mesh = adjust_facing(facing_mesh, dir, delta, 1.0 / horizontal_speed * TURN_SPEED, Vector3.UP)
		var m3 = Basis(-facing_mesh, Vector3.UP, -facing_mesh.cross(Vector3.UP).normalized()).scaled(CHAR_SCALE)

		get_node("Frame").set_transform(Transform(m3, mesh_xform.origin))
		
		
		if jump_attempt:
			print("Attempted To Jump")
			if (not is_jumping): #check to make sure player is not already jumping
				if jump_attempt: 
					is_jumping = true
					vertical_velocity = J_VEL
				
	else: #Player is in the Air
		if dir.length() > 0.1:
			horizontal_velocity += dir * (ACCEL * AIR_ACCEL_FACTOR * delta)
			if horizontal_velocity.length() > MAX_SPEED:
				horizontal_velocity = horizontal_velocity.normalized() * MAX_SPEED
		elif A_I_DEACCEL:
			horizontal_speed = horizontal_speed - (DEACCEL * AIR_ACCEL_FACTOR * delta)
			if horizontal_speed < 0:
				horizontal_speed = 0
			horizontal_velocity = horizontal_dir * horizontal_speed

	if is_jumping and vertical_velocity < 0:
		is_jumping = false

	linear_velocity = horizontal_velocity + Vector3.UP * vertical_velocity
		
	
	if is_on_floor():
		movement_dir = linear_velocity

	linear_velocity = move_and_slide(linear_velocity, -gravity.normalized())		
		




func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
	var n = p_target # Normal.
	var t = n.cross(current_gn).normalized()


	var y = t.dot(p_facing)
	var x = n.dot(p_facing)
	

	var ang = atan2(y,x)

	if abs(ang) < 0.001: # if the change in angle is too small.
		return p_facing

	var a
	var s = sign(ang)
	
	ang = ang * s
	var tn = ang * p_adjust_rate * p_step
	
	if(ang < tn):
		a = ang
		

	else:
		a = tn
	ang = (ang - a) * s
	return (n * cos(ang) + t * sin(ang)) * p_facing.length()		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

