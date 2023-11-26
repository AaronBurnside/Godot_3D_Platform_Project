extends Camera


const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0

export var min_distance = 0.5
export var max_distance = 3.5
export var angle_v_adjust = 0.0
export var autoturn_ray_aperture = 25
export var autoturn_speed = 50

var collision_exception = []


func _ready():
	var node = self
	
	while node:
		if node is RigidBody:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
			
	set_physics_process(true)
	set_as_toplevel(true)


func _physics_process(delta):
	var target = get_parent().get_global_transform().origin
	var cam_position = get_global_transform().origin

	var dis_change = cam_position - target


	# check the ranges.
	if dis_change.length() < min_distance:
		dis_change = dis_change.normalized() * min_distance
	elif  dis_change.length() > max_distance:
		dis_change = dis_change.normalized() * max_distance

	# Check upper and lower height.
	dis_change.y = clamp(dis_change.y, MIN_HEIGHT, MAX_HEIGHT)

	# Check autoturn.
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())

	var col_left = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(autoturn_ray_aperture)).xform(dis_change), collision_exception)
	var col = ds.intersect_ray(target, target + dis_change, collision_exception)
	var col_right = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(-autoturn_ray_aperture)).xform(dis_change), collision_exception)

	if (not col.empty()):
		dis_change = col.position - target
		
	elif (not col_left.empty()) and (col_right.empty()):
		dis_change = Basis(Vector3.UP, deg2rad(-delta * autoturn_speed)).xform(dis_change)
	
	elif (col_left.empty() and not col_right.empty()):
		dis_change = Basis(Vector3.UP, deg2rad(delta  *autoturn_speed)).xform(dis_change)

	# change camera position and apply look at.
	if dis_change == Vector3():
		dis_change = (cam_position - target).normalized() * 0.0001

	cam_position = target + dis_change

	look_at_from_position(cam_position, target, Vector3.UP)

	# Turn a little up or down.
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
	set_transform(t)
