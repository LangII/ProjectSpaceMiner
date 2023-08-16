

"""
--------------
BEHAVIOR NOTES
--------------

- MOTION STATES
	- on wall
		- walking
		- turning
			- concave
			- convex
	- floating
	- landing (transition from floating to on wall (transition from on wall to floating is instant))
- ATTACK STATES
	- can shoot (based on cool down)
	- is looking at ship (turret is pointed at ship)
	- is targeting ship (turret is turning towards ship)
	- ship is in range
	- ready
	- 
"""


extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')

var move_state = ''
var move_vector = Vector2()

#var WALK_ANGLES = [0, 45, 90, 135, 180, 225, 270, 315, 360]
#var WALK_ANGLE_TOLERANCE = 20

#var ROT_NODE_MAP = {
#	$RotPosA: {
#		'next_pos_node':	{'right': $RotPosD,			'left': $RotPosB},
#		'col_ray':			{'right': $ColRayARight,	'left': $ColRayALeft}
#	},
#	$RotPosB: {
#		'next_pos_node':	{'right': $RotPosA,			'left': $RotPosC},
#		'col_ray':			{'right': $ColRayBRight,	'left': $ColRayBLeft}
#	},
#	$RotPosC: {
#		'next_pos_node':	{'right': $RotPosB,			'left': $RotPosD},
#		'col_ray':			{'right': $ColRayCRight,	'left': $ColRayCLeft}
#	},
#	$RotPosD: {
#		'next_pos_node':	{'right': $RotPosC,			'left': $RotPosA},
#		'col_ray':			{'right': $ColRayDRight,	'left': $ColRayDLeft}
#	}
#}

"""
TURNOER NOTES:
- I think it might be the map that's so wrong.  The Enemy03's rotation seems to coordinatedly skip
corners during rotation.  ^|_(**)_|^
"""

var ROT_NODE_MAP = {
	'RotPosA': {
		'next_pos_node':	{'right': 'RotPosD',		'left': 'RotPosB'},
		'col_ray':			{'right': 'ColRayARight',	'left': 'ColRayALeft'}
	},
	'RotPosB': {
		'next_pos_node':	{'right': 'RotPosA',		'left': 'RotPosC'},
		'col_ray':			{'right': 'ColRayBRight',	'left': 'ColRayBLeft'}
	},
	'RotPosC': {
		'next_pos_node':	{'right': 'RotPosB',		'left': 'RotPosD'},
		'col_ray':			{'right': 'ColRayCRight',	'left': 'ColRayCLeft'}
	},
	'RotPosD': {
		'next_pos_node':	{'right': 'RotPosC',		'left': 'RotPosA'},
		'col_ray':			{'right': 'ColRayDRight',	'left': 'ColRayDLeft'}
	}
}

var cur_rotate_around_node = null
var cur_rotate_around_pos = Vector2()
var cur_rotate_dir = ''
var cur_rotated_enough_ray = null

var can_change_col_ray = true


####################################################################################################


func _ready():
	
	move_state = 'floating'
#	move_state = 'testing'
	
#	$WalkingTerrainCol.disabled = true
	
	move_vector = Vector2(0, 100)
	
	rotate(deg2rad(10))
	
#	rotate_around = $RotPosD.global_position


var d = 0.0

func _process(_delta:float):
#func _physics_process(_delta:float):
	
#	print("\ncur_rotate_around_node.name = ", cur_rotate_around_node.name if cur_rotate_around_node else null)
#	print("cur_rotated_enough_ray.name = ", cur_rotated_enough_ray.name if cur_rotated_enough_ray else null)
	
#	d += _delta
	
	match move_state:
		
		'floating':
			
			var col = move_and_collide(move_vector * _delta, false)
			
			if col:
				
				if col.collider == tilemap:
					
#					print("\ncol.position = ", col.position)
					
#					print("collided with tilemap")
					
#					rotateToWalkFromCol(col.position)
					
					# ignore terrain col while walking
					set_collision_mask_bit(1, false)
					
					smallRotateAfterTerrainCol(col.position)
					
					move_state = 'rotating'
					
#					rotate_around = $RotPosD.global_position
#					cur_rotate_around = col.position
					cur_rotate_around_node = getClosestRotPosNode(col.position)
					
					cur_rotate_around_pos = cur_rotate_around_node.global_position
					
					cur_rotate_dir = 'right'
					
					cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_rotate_dir])
					
					can_change_col_ray = true
					
					printColVars()
					
#					$FloatingTerrainCol.disabled = true
#					$WalkingTerrainCol.disabled = false
					
#					var crap_speed = 5000.0
#					global_position = Vector2(
#						sin(crap_speed) * global_position.distance_to(rotate_around),
#						cos(crap_speed) * global_position.distance_to(rotate_around)
#					) + rotate_around
					
		
		'rotating':
			
			print("\ncur_rotated_enough_ray.name           = ", cur_rotated_enough_ray.name)
			print("cur_rotated_enough_ray.is_colliding() = ", cur_rotated_enough_ray.is_colliding())
#			if hasRotatedEnough():
#			cur_rotated_enough_ray.force_raycast_update()
				
			if cur_rotated_enough_ray.is_colliding() and can_change_col_ray:
				
#				print("HAS ROTATED ENOUGH")
				updateColVars()
				printColVars()
#				return
#				updateCurRotateAround()
#				updateCurRotatedEnoughRay()
#				cur_rotate_around_node = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['next_pos_node'][cur_rotate_dir])
#				cur_rotate_around_pos = cur_rotate_around_node.global_position
#				cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_rotate_dir])
#				can_change_col_ray = false
#				$CanChangeColRayTimer.start()
#
			global_position = cur_rotate_around_pos + (global_position - cur_rotate_around_pos).rotated(0.02)
#			look_at(cur_rotate_around_pos)
			rotate(deg2rad(1))
			
#			var rot_speed = -1.0
#			d += _delta
#			d = 1
#			var sin_ = sin(rot_speed * d) * global_position.distance_to(rotate_around)
#			var cos_ = cos(rot_speed * d) * global_position.distance_to(rotate_around)
#			print("sin_ = ", sin_)
#			print("cos_ = ", cos_)
#			global_position = Vector2(
#				sin(rot_speed * d) * global_position.distance_to(rotate_around),
#				cos(rot_speed * d) * global_position.distance_to(rotate_around)
#			) + rotate_around
#			print("cur_rotate_around_node = ", cur_rotate_around_node)
			
			
		
		'passive':
			
			pass





















#		'testing':
#
#			var rot_speed = 2.0
#
##			var sin_var = sin(rot_speed * _delta)
##			print("sin_var = ", sin_var)
#
#			d += _delta
#
#			global_position = Vector2(
##				sin(rot_speed * _delta) * global_position.distance_to(rotate_around),
#				sin(rot_speed * d) * global_position.distance_to(rotate_around),
##				cos(rot_speed * _delta) * global_position.distance_to(rotate_around)
#				cos(rot_speed * d) * global_position.distance_to(rotate_around)
#			) + rotate_around
#
#			look_at(rotate_around)
#			rotate(deg2rad(90 + 45))


####################################################################################################


func updateColVars() -> void:
	cur_rotate_around_node = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['next_pos_node'][cur_rotate_dir])
	cur_rotate_around_pos = cur_rotate_around_node.global_position
	cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_rotate_dir])
	
	can_change_col_ray = false
	$CanChangeColRayTimer.start()


func printColVars() -> void:
	print("\ncur_rotate_around_node = ", cur_rotate_around_node.name)
	print("cur_rotate_around_pos  = ", cur_rotate_around_pos)
	print("cur_rotate_dir         = ", cur_rotate_dir)
	print("cur_rotated_enough_ray = ", cur_rotated_enough_ray.name)


func smallRotateAfterTerrainCol(_col_pos:Vector2) -> void:
	
	var closest_rot_pos_node_name = getClosestRotPosNode(_col_pos).name
#	print("closest_rot_pos_node_name = ", closest_rot_pos_node_name)
	
	var closest_rot_pos_v = global_position - getClosestRotPosNode(_col_pos).global_position
	var col_pos_v = global_position - _col_pos
	var angle_to = closest_rot_pos_v.angle_to(col_pos_v)
	rotate(angle_to)


func hasRotatedEnough() -> bool:
	
#	print("\nstarted hasRotatedEnough()")
	
	if not cur_rotated_enough_ray.is_colliding():  return false
	
#	print("cur_rotated_enough_ray.get_collision_point() = ", cur_rotated_enough_ray.get_collision_point())
	
	var dist_to_tilemap = cur_rotated_enough_ray.global_position.distance_to(cur_rotated_enough_ray.get_collision_point())
	
#	print("dist_to_tilemap = ", dist_to_tilemap)
	
	if dist_to_tilemap < 2.0:  return true
	
	return false


func getClosestRotPosNode(_pos:Vector2) -> Node:
	var closest_rot_pos_node_ = null
	var rot_pos_nodes = ROT_NODE_MAP.keys()
	
#	print("rot_pos_nodes = ", rot_pos_nodes)
	
	var dists = [
		$RotPosA.global_position.distance_to(_pos), $RotPosB.global_position.distance_to(_pos),
		$RotPosC.global_position.distance_to(_pos), $RotPosD.global_position.distance_to(_pos)
	]
	closest_rot_pos_node_ = get_node(rot_pos_nodes[dists.find(dists.min())])
	return closest_rot_pos_node_


#func rotateToWalkFromCol(_col_pos:Vector2) -> void:
#
#	# left = 0, right = 180, down = 270, up = 90
#	var col_angle = util.convAngleTo360Range(rad2deg(global_position.angle_to_point(_col_pos)))
#	print("col_angle = ", col_angle)
#
#	return





func _on_CanChangeColRayTimer_timeout():
	can_change_col_ray = true
