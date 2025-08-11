

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

-----
TODOS
-----

2025-07-04

updates for when Enemy03 goes underground / mole-mode...

- need to add a sensor which just simply checks to see if the center of Enemy03 is inside a terrain
tile or not.  then collect data over time and add a timer to see how_long_underground

- while underground / mole-mode, do small amounts of damage to terrain tiles that that Enemy03 "is
behind"

- code soem "break through" activity where if Enemy03 is underground for too long, just simply teleport
itself to above ground but in "float" state floating back towards previous location (add some form of
particle animation so it won't look so cheap)

-------------------
LOW PRIORITY TO DOS
-------------------

2024-08-07
The roll behavior definitely still needs work.  For the majority of the time it works perfectly as
intended.  But in tight corners where it has to make many turns back to back, it can roll "into" or
"behind" the terrain.

2024-08-06
When avoiding rolling on Permanent Air tiles, when Enemy03 changes direction away from the
Permanent Air tiles, it can sometimes do an unusal movement where it rolls into the terrain once and
then when it comes back around to the surface it will then continue its roll as intended.

One problem with the current method of "rolling" is that I don't know how to make the roll speed
adjustable.
"""


extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')
onready var data = get_node('/root/Main/Data')

onready var missile_01 = preload('res://scenes/Missile01.tscn')

var ROT_NODE_MAP = {
	'RotPosA': {
		'next_pos_node':		{'right': 'RotPosD',			'left': 'RotPosB'},
		'col_ray':			{'right': 'ColRayARight',	'left': 'ColRayALeft'}
	},
	'RotPosB': {
		'next_pos_node':		{'right': 'RotPosA',			'left': 'RotPosC'},
		'col_ray':			{'right': 'ColRayBRight',	'left': 'ColRayBLeft'}
	},
	'RotPosC': {
		'next_pos_node':		{'right': 'RotPosB',			'left': 'RotPosD'},
		'col_ray':			{'right': 'ColRayCRight',	'left': 'ColRayCLeft'}
	},
	'RotPosD': {
		'next_pos_node':		{'right': 'RotPosC',			'left': 'RotPosA'},
		'col_ray':			{'right': 'ColRayDRight',	'left': 'ColRayDLeft'}
	}
}

onready var FLOATING_LINEAR_SPEED_MIN = util.coalesce([null, ctrl.enemy03_floating_linear_speed_min])
onready var FLOATING_LINEAR_SPEED_MAX = util.coalesce([null, ctrl.enemy03_floating_linear_speed_max])
onready var FLOATING_ROTATE_SPEED_MIN = util.coalesce([null, ctrl.enemy03_floating_rotate_speed_min])
onready var FLOATING_ROTATE_SPEED_MAX = util.coalesce([null, ctrl.enemy03_floating_rotate_speed_max])

onready var ROLLING_CHANGE_DIR_CHANCE_MIN = util.coalesce([null, ctrl.enemy03_rolling_change_dir_chance_min])  # perc
onready var ROLLING_CHANGE_DIR_CHANCE_MAX = util.coalesce([null, ctrl.enemy03_rolling_change_dir_chance_max])  # perc

onready var ROLLING_MOV_MOD = util.coalesce([null, ctrl.enemy03_rolling_mov_mod])
onready var ROLLING_ROT_MOD = util.coalesce([null, ctrl.enemy03_rolling_rot_mod])

onready var CAN_DMG_SHIP_DELAY = util.coalesce([null, ctrl.enemy03_can_dmg_ship_delay])
onready var COL_WITH_SHIP_SPEED_MOD = util.coalesce([null, ctrl.enemy03_col_with_ship_speed_mod])  # perc

onready var SHIP_COL_IMPULSE_MOD = util.coalesce([null, ctrl.enemy03_ship_col_impulse_mod])

onready var MAX_HEALTH = util.coalesce([null, ctrl.enemy03_max_health])
onready var DMG = util.coalesce([null, ctrl.enemy03_dmg])
onready var DMG_TO_SELF_MOD = util.coalesce([null, ctrl.enemy03_dmg_to_self_mod])

onready var WOUNDED_MAP = {
	'high': {
		'min': util.coalesce([null, ctrl.enemy03_wounded_map_high_min]),
		'max': util.coalesce([null, ctrl.enemy03_wounded_map_high_max]),
		'speed': util.coalesce([null, ctrl.enemy03_wounded_map_high_speed])
	},
	'low': {
		'min': util.coalesce([null, ctrl.enemy03_wounded_map_low_min]),
		'max': util.coalesce([null, ctrl.enemy03_wounded_map_low_max]),
		'speed': util.coalesce([null, ctrl.enemy03_wounded_map_low_speed])
	}
}

onready var TURRET_ROT_SPEED_MIN = util.coalesce([null, ctrl.enemy03_turret_rot_speed_min])
onready var TURRET_ROT_SPEED_MAX = util.coalesce([null, ctrl.enemy03_turret_rot_speed_max])
onready var CAN_SHOOT_MISSILE_DELAY = util.coalesce([null, ctrl.enemy03_can_shoot_missile_delay])

onready var TURRET_IS_NEAR_WALL_MIN = util.coalesce([null, ctrl.enemy03_turret_is_near_wall_min])

onready var SHIP_DETECT_RAY_DIST = util.coalesce([null, ctrl.enemy03_ship_detect_ray_dist])

onready var DROP_VALUE_MIN = util.coalesce([null, ctrl.enemy03_drop_value_min])
onready var DROP_VALUE_MAX = util.coalesce([null, ctrl.enemy03_drop_value_max])

var move_state = ''  # 'floating' or 'rolling'

var cur_rotate_around_node = null
var cur_rotate_around_pos = Vector2()
var cur_roll_dir = ''
var cur_roll_dir_mod = 0
var cur_rotated_enough_ray = null

var floating_linear_speed = 0.0
var floating_linear_dir = 0.0
var floating_move_vector = Vector2()
var floating_rotate_speed = 0.0
var floating_rotate_dir = ''
var floating_rotate_dir_mod = 0

var cur_holding_tile = null
var cur_holding_tile_code = null

var can_dmg_ship = true

onready var health = MAX_HEALTH

var WOUNDED_COLOR = Color(1, 0.4, 0.4, 1)  # red
var wounded_level = null

var turret_rot_speed = 0.8

onready var turret = get_node('TurretNonSpatial/TurretPivot')

var can_shoot_missile = false

var turret_rot_dir = 0
var turret_rot_speed_dir = +1

onready var WALL_DETECTION_COL_RAYS_MAP = [
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayL'),	'dir': 'left',			'dir_deg': 0},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayTL'),	'dir': 'top_left',		'dir_deg': 45},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayT'),	'dir': 'top',			'dir_deg': 90},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayTR'),	'dir': 'top_right',		'dir_deg': 135},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayR'),	'dir': 'right',			'dir_deg': 180},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayBR'),	'dir': 'bottom_right',	'dir_deg': 225},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayB'),	'dir': 'bottom',			'dir_deg': 270},
	{'node': get_node('WallDetectionNonSpatial/WallDetectionPos/ColRayBL'),	'dir': 'bottom_left',	'dir_deg': 315},
]

var wall_detection_dir = ''
var wall_detection_dir_deg = 0

var turret_is_near_wall = false
var turret_is_rot_towards_wall = false

var turret_wall_deg_dif = 0
var prev_turret_wall_deg_dif = 0

var is_detecting_ship = false

var turret_rot_frame_drop = 60

var missile_load_inc = 1.2
var missile_load_dec = 0.4
var missile_load_max = 100.0
var missile_load = 0.0

var drop_value = 0


####################################################################################################


func _ready() -> void:
	
	pass


func init(_dir:int) -> void:
	
	$CanDmgShipTimer.wait_time = CAN_DMG_SHIP_DELAY
	$TurretNonSpatial/TurretPivot/ShipDetectRay.cast_to.x = -SHIP_DETECT_RAY_DIST
	
	setMoveStateToFloating()
	
	drop_value = util.getRandomInt(DROP_VALUE_MIN, DROP_VALUE_MAX)
	
	floating_move_vector = Vector2(floating_linear_speed, 0).rotated(deg2rad(_dir))


func _process(_delta:float) -> void:
	
	match move_state:
		
		'floating':
			
			rotate(floating_rotate_dir_mod * floating_rotate_speed)
			
			var col = move_and_collide(floating_move_vector * _delta, false)
			
			if col:
				
				if col.collider == tilemap:
					
					if isColWithPermanentAir(col):
						
						floating_move_vector = floating_move_vector.rotated(deg2rad(180))
					
					else:
					
						setMoveStateToRolling(col.position)
					
				elif col.collider == ship and can_dmg_ship:  colWithShip(col.collider)
		
		'rolling':
			
			if cur_rotated_enough_ray.is_colliding():
				
				setCurHoldingTileVars()
				
				# stop rolling on Permanet Air tiles
				if cur_holding_tile_code == 2:  changeCurRollDir()
				
				elif util.getRandomBool(
					util.getRandomFloat(
						ROLLING_CHANGE_DIR_CHANCE_MIN, ROLLING_CHANGE_DIR_CHANCE_MAX
					)
				):
					
					changeCurRollDir()
					
					setCurRotatedEnoughRay()
				
				else:
				
					updateColVars()
			
			handleRollingMovement()
			
			var col = move_and_collide(Vector2(), false, true, true)
			
			if col and col.collider == ship and can_dmg_ship:  colWithShip(col.collider)

	setNonSpatialsPos()
	
	handleTurretRotation()
	
	if $TurretNonSpatial/TurretPivot/ShipDetectRay.is_colliding():
		
		is_detecting_ship = true
		
		updateTurretRotSpeedDirToTargetShip()
		
		handleMissileLoad('inc')
	
	else:
		
		is_detecting_ship = false
		
		handleMissileLoad('dec')


####################################################################################################


func setMoveStateToFloating() -> void:
	move_state = 'floating'
	floating_linear_speed = util.getRandomFloat(FLOATING_LINEAR_SPEED_MIN, FLOATING_LINEAR_SPEED_MAX)
	floating_linear_dir = util.getRandomFloat(0.0, 360.0)
	floating_move_vector = Vector2(floating_linear_speed, 0).rotated(deg2rad(floating_linear_dir))
	floating_rotate_speed = util.getRandomFloat(FLOATING_ROTATE_SPEED_MIN, FLOATING_ROTATE_SPEED_MAX)
	floating_rotate_dir = util.getRandomItemFromArray(['left', 'right'])
	floating_rotate_dir_mod = -1 if floating_rotate_dir == 'left' else +1
	set_collision_mask_bit(1, true)
	cur_holding_tile = null


func setMoveStateToRolling(_col_position:Vector2) -> void:
	set_collision_mask_bit(1, false)  # ignore terrain col while walking
	smallRotateAfterTerrainCol(_col_position)
	move_state = 'rolling'
	cur_rotate_around_node = getClosestRotPosNode(_col_position)
	cur_rotate_around_pos = cur_rotate_around_node.global_position
	cur_roll_dir = util.getRandomItemFromArray(['left', 'right'])
	cur_roll_dir_mod = -1 if cur_roll_dir == 'left' else +1
	setCurRotatedEnoughRay()


func setCurRotatedEnoughRay() -> void:
	cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_roll_dir])


func handleRollingMovement() -> void:
	global_position = (
		cur_rotate_around_pos
		+ (global_position - cur_rotate_around_pos).rotated(cur_roll_dir_mod * ROLLING_MOV_MOD)
	)
	rotate(deg2rad(cur_roll_dir_mod * ROLLING_ROT_MOD))


func updateColVars() -> void:
	cur_rotate_around_node = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['next_pos_node'][cur_roll_dir])
	cur_rotate_around_pos = cur_rotate_around_node.global_position
	cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_roll_dir])


func printColVars() -> void:
	print("\ncur_rotate_around_node = ", cur_rotate_around_node.name)
	print("cur_rotate_around_pos  = ", cur_rotate_around_pos)
	print("cur_roll_dir           = ", cur_roll_dir)
	print("cur_rotated_enough_ray = ", cur_rotated_enough_ray.name)


func smallRotateAfterTerrainCol(_col_pos:Vector2) -> void:
	var closest_rot_pos_node_name = getClosestRotPosNode(_col_pos).name
	var closest_rot_pos_v = global_position - getClosestRotPosNode(_col_pos).global_position
	var col_pos_v = global_position - _col_pos
	var angle_to = closest_rot_pos_v.angle_to(col_pos_v)
	rotate(angle_to)


func getClosestRotPosNode(_pos:Vector2) -> Node:
	var closest_rot_pos_node_ = null
	var rot_pos_nodes = ROT_NODE_MAP.keys()
	var dists = [
		$RotPosA.global_position.distance_to(_pos), $RotPosB.global_position.distance_to(_pos),
		$RotPosC.global_position.distance_to(_pos), $RotPosD.global_position.distance_to(_pos)
	]
	closest_rot_pos_node_ = get_node(rot_pos_nodes[dists.find(dists.min())])
	return closest_rot_pos_node_


func changeCurRollDir() -> void:
	cur_roll_dir = 'left' if cur_roll_dir == 'right' else 'right'
	cur_roll_dir_mod = -1 if cur_roll_dir_mod == +1 else +1


func setCurHoldingTileVars() -> void:
	var col_point = cur_rotated_enough_ray.get_collision_point()
	var col_point_ext = (col_point - global_position).clamped(0.1)
	cur_holding_tile = tilemap.world_to_map(col_point + col_point_ext)
	cur_holding_tile_code = data.tiles['%s,%s' % [cur_holding_tile.y, cur_holding_tile.x]]['tile_code']


func setNonSpatialsPos() -> void:
	$TurretNonSpatial/TurretPivot.global_position = global_position
	$WallDetectionNonSpatial/WallDetectionPos.global_position = global_position


func handleTurretRotation() -> void:
	
	# to decrease speed of turret rotation when targeting ship, i had to make it so that the turret
	# will only rotate during certain frames.  this is because even with a massive drop in speed,
	# the turrets rotation still maintained targeting of ship
	if is_detecting_ship:
		if Engine.get_frames_drawn() % turret_rot_frame_drop != 0:  return
	
	# continuous turret movement
	turret.rotate(deg2rad(turret_rot_speed * turret_rot_speed_dir))
	turret_rot_dir = int(turret.rotation_degrees) % 360
	# handle when turret needs to change directions
	if move_state == 'rolling':
		setWallDetectionVars()
		setWallDegDifVars()
		setTurretIsVars()
		if turret_is_near_wall and turret_is_rot_towards_wall:  turret_rot_speed_dir *= -1


func setWallDetectionVars() -> void:
	for map in WALL_DETECTION_COL_RAYS_MAP:
		if map['node'].is_colliding():
			wall_detection_dir = map['dir']
			wall_detection_dir_deg = map['dir_deg']
			break


func setWallDegDifVars() -> void:
	prev_turret_wall_deg_dif = turret_wall_deg_dif
	turret_wall_deg_dif = abs(util.anglesDif(turret_rot_dir, wall_detection_dir_deg))


func setTurretIsVars() -> void:
	turret_is_near_wall = turret_wall_deg_dif < TURRET_IS_NEAR_WALL_MIN
	turret_is_rot_towards_wall = prev_turret_wall_deg_dif > turret_wall_deg_dif


func printTurretVars() -> void:		
	print("\nturret_rot_speed_dir       = ", turret_rot_speed_dir)
	print("turret_rot_dir             = ", turret_rot_dir)
	print("turret_rot_speed           = ", turret_rot_speed)
	print("wall_detection_dir         = ", wall_detection_dir)
	print("wall_detection_dir_deg     = ", wall_detection_dir_deg)
	print("turret_wall_deg_dif        = ", turret_wall_deg_dif)
	print("turret_is_near_wall        = ", turret_is_near_wall)
	print("turret_is_rot_towards_wall = ", turret_is_rot_towards_wall)


func handleMissileLoad(_type:String) -> void:
	match _type:
		'inc':  missile_load += missile_load_inc
		'dec':  missile_load -= missile_load_dec
	if missile_load < 0.0:  missile_load = 0.0
	if missile_load >= missile_load_max:
		shootMissile()
		missile_load = 0.0
	# update turret sprite color with missile_load value
	var color = util.normalize(missile_load, 0.0, missile_load_max, 1.0, 0.4)
	$TurretNonSpatial/TurretPivot/TurretSprite.modulate = Color(1.0, color, color, 1.0)


func shootMissile() -> void:
	$TurretNonSpatial/TurretPivot/ShootMissileParticles2D.restart()
	var missile = missile_01.instance()
	gameplay.get_node('Projectiles').add_child(missile)
	missile.start(
		$TurretNonSpatial/TurretPivot/BulletSpawn.global_position,
		$TurretNonSpatial/TurretPivot/BulletSpawn.global_rotation
	)


func updateTurretRotSpeedDirToTargetShip() -> void:
	if not is_detecting_ship:  return
	var ship_rot_dir = util.convAngleTo360Range2(rad2deg(global_position.angle_to_point(ship.global_position)))
	var turret_ship_angles_dif = util.anglesDif(turret_rot_dir, ship_rot_dir) + 0.00001
	turret_rot_speed_dir = turret_ship_angles_dif / abs(turret_ship_angles_dif)


func isColWithPermanentAir(_col:KinematicCollision2D) -> bool:
	var mod_normal = _col.normal.limit_length(0.01)
	var tile_pos = tilemap.world_to_map(_col.position - mod_normal)
#	print("\ntile_pos = ", tile_pos)
	if data.tiles['%s,%s' % [tile_pos.y, tile_pos.x]]['tile_code'] == 2:  return true
	return false


####################################################################################################


func colWithShip(_collider):
	can_dmg_ship = false
	$CanDmgShipTimer.start()
	ship.takeDmg(DMG)
	floating_linear_speed *= COL_WITH_SHIP_SPEED_MOD
	floating_linear_dir = util.convAngleTo360Range(
		rad2deg(
			_collider.global_position.angle_to_point(global_position)
		) * -1
	) + 180
	floating_move_vector = Vector2(floating_linear_speed, 0).rotated(deg2rad(floating_linear_dir))
	takeDmg(DMG * DMG_TO_SELF_MOD)


func takeDmg(_dmg:int, _node_took_dmg:Object=self) -> void:
	health -= _dmg
	if health <= 0:  startQueueFreeSequence()
	setWoundedLevel()
	if wounded_level:  startWoundedTweenUp()


func startQueueFreeSequence():
	setMoveStateToFloating()
	floating_move_vector = Vector2()
	floating_rotate_speed = 0.0
	collision_layer = 0
	collision_mask = 0
	$Sprite.visible = false
	$TurretNonSpatial/TurretPivot/TurretSprite.visible = false
	$LifeEndParticles2D.restart()
	$LifeEndParticlesLifeTimeTimer.start()
	gameplay.initDrop('enemy_03', drop_value, global_position)


func startWoundedTweenUp():
	if not wounded_level:  return
	$WoundedTweenUp.interpolate_property(
		$Sprite, 'modulate', Color(1, 1, 1, 1), WOUNDED_COLOR,
		WOUNDED_MAP[wounded_level]['speed'], 0, 1
	)
	$WoundedTweenUp.start()


func startWoundedTweenDown():
	if not wounded_level:  return
	$WoundedTweenDown.interpolate_property(
		$Sprite, 'modulate', WOUNDED_COLOR, Color(1, 1, 1, 1),
		WOUNDED_MAP[wounded_level]['speed'], 0, 1
	)
	$WoundedTweenDown.start()


func setWoundedLevel():
	for level in WOUNDED_MAP.keys():
		var wounded_health_min = MAX_HEALTH * WOUNDED_MAP[level]['min']
		var wounded_health_max = MAX_HEALTH * WOUNDED_MAP[level]['max']
		if (health > wounded_health_min) and (health <= wounded_health_max):
			wounded_level = level
			return
	wounded_level = null


####################################################################################################


func _on_WoundedTweenUp_tween_all_completed():
	if wounded_level:  startWoundedTweenDown()


func _on_WoundedTweenDown_tween_all_completed():
	if wounded_level:  startWoundedTweenUp()


func _on_CanDmgShipTimer_timeout():
	can_dmg_ship = true


func _on_LifeEndParticlesLifeTimeTimer_timeout():
	queue_free()


func _on_CanShootMissileDelayTimer_timeout():
	can_shoot_missile = true

