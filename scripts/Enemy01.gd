
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')

var HOME_POS = Vector2()
var HOME_RADIUS_BY_TILE = 0
onready var HOME_RADIUS = HOME_RADIUS_BY_TILE * tilemap.cell_size[0]

var ROT_DIRS = ['left', 'right']
var ROT_SPEED = 4.0
var MOVE_SPEED = 150.0

var AGGRESSIVE_DIST_RANGE = 400.0

var TARGET_ANGLE_RANGE = 10.0

var MASTER_ROT_DELAY_TIME = 0.2
var MASTER_ROT_MIN_TIME = 0.5
var MASTER_ROT_MAX_TIME = 2.0
var MASTER_MOVE_DELAY_TIME = 0.2
var MASTER_MOVE_MIN_TIME = 0.5
var MASTER_MOVE_MAX_TIME = 1.5

var MAX_HEALTH = 80.0

var DMG = 10.0
var DMG_TO_SELF_MOD = 0.5

var CAN_DMG_SHIP_DELAY = 0.5
var SHIP_COL_IMPULSE_MOD = 80.0
var can_dmg_ship = true

var master_behavior = ''  # ['rot_delay', 'rot', 'move_delay', 'move', 'queue_free_sequence']
var target_behavior = ''  # ['patrol', 'retreat']
var pursue_trail = []
var is_home = true

var rot_dir = ''

var master_move_vector = Vector2()
var rotated_enough = false

var master_target_pos = Vector2()
var master_target_vector = Vector2()

var targeting = null

var PURSUE_CHANCE_REDUCTION = 0.25

var health = MAX_HEALTH

var WOUNDED_MAP = {
	'high': {'min': 0.0, 'max': 0.25, 'speed': 0.25},
	'low': {'min': 0.25, 'max': 0.5, 'speed': 1.0}
}
var WOUNDED_COLOR = Color(1, 0.4, 0.4, 1)  # red
var wounded_level = null

var LIFEEND_PARTICLES_LIFETIME = 1.0

var DROP_VALUE_MIN = 1
var DROP_VALUE_MAX = 3
var drop_value = 0


####################################################################################################


func _ready():
	
	master_behavior = 'rot_delay'
	
	target_behavior = 'patrol'
	
	$AggressiveRay.cast_to = Vector2(0, -AGGRESSIVE_DIST_RANGE)
	
	$MasterRotDelayTimer.wait_time = MASTER_ROT_DELAY_TIME
	$MasterMoveDelayTimer.wait_time = MASTER_MOVE_DELAY_TIME
	
	$LifeEndParticles2D.lifetime = LIFEEND_PARTICLES_LIFETIME
	$LifeEndParticlesLifeTimeTimer.wait_time = LIFEEND_PARTICLES_LIFETIME
	
	$MasterRotDelayTimer.start()
	
	$CanDmgShipTimer.wait_time = CAN_DMG_SHIP_DELAY
	
	rot_dir = util.getRandomItemFromArray(ROT_DIRS)
	
	setMasterTargetPosAndVector()
	setAndStartMasterRotTime()
	
	startWoundedTweenUp()
	
	drop_value = util.getRandomInt(DROP_VALUE_MIN, DROP_VALUE_MAX)


func _process(delta):
	
	match master_behavior:
#
		'rot_delay':  pass
		
		'rot':
			
			standardRotate()
			if target_behavior == 'patrol':
				targeting = $AggressiveRay.get_collider()
				if targeting and targeting.name == 'Ship' and can_dmg_ship:
					pursue_trail += [targeting.global_position]
					updateMasterBehaviorToMove()
					updateTargetBehavior()
					return
			
			if rotated_enough and masterTargetIsWithinAngularRange():
				updateMasterBehaviorToMove()
				if pursue_trail:
					target_behavior = 'retreat'
		
		'move_delay':  pass
		
		'move':  pass
		
		'queue_free_sequence':  pass
		
	var col = move_and_collide(master_move_vector * delta,  false)
	
	if col:
		
		if col.collider == ship and can_dmg_ship:
			
			colWithShip(col)
			
			master_move_vector = Vector2(0, 0)
			master_behavior = 'rot_delay'
			$MasterRotDelayTimer.start()
			
			gameplay.setEnemyColParticles(col.position)


####################################################################################################


func setMasterTargetPosAndVector():
	
	if target_behavior == 'retreat' and pursue_trail:
		master_target_pos = pursue_trail.pop_back()
	else:
	
		var pass_target_rot = util.getRandomFloat(0.0, 360.0)
		var pass_target_dist = util.getRandomFloat(0.0, HOME_RADIUS)
		master_target_pos = HOME_POS + (Vector2(pass_target_dist, 0).rotated(deg2rad(pass_target_rot)))
		
	master_target_vector = master_target_pos - global_position


func setAndStartMasterRotTime():
	rotated_enough = false
	$MasterRotTimer.wait_time = util.getRandomFloat(MASTER_ROT_MIN_TIME, MASTER_ROT_MAX_TIME)
	$MasterRotTimer.start()


func standardRotate():
	match rot_dir:
		'left':  rotation_degrees -= ROT_SPEED
		'right':  rotation_degrees += ROT_SPEED


func masterTargetIsWithinAngularRange() -> bool:
	var looking_at_vector = $LookingAtPos.global_position - global_position
	var angle_to_target = rad2deg(looking_at_vector.angle_to(master_target_vector))
	return abs(angle_to_target) < TARGET_ANGLE_RANGE


func updateMasterBehaviorToMove():
	master_behavior = 'move_delay'
	var move_angle = global_position.angle_to_point($LookingAtPos.global_position)
	master_move_vector = Vector2(-MOVE_SPEED, 0).rotated(move_angle)
	$MasterMoveDelayTimer.start()


func updateIsHomeAndPursue():
	is_home = global_position.distance_to(HOME_POS) <= HOME_RADIUS
	if is_home:
		target_behavior = 'patrol'
		pursue_trail = []


func updateTargetBehavior():
	var pursue_chance = 1.0
	for _i in len(pursue_trail):  pursue_chance *= (1.0 - PURSUE_CHANCE_REDUCTION)
	if util.getRandomBool(pursue_chance):  target_behavior = 'patrol'
	else:  target_behavior = 'retreat'


func colWithShip(_collider):
	can_dmg_ship = false
	$CanDmgShipTimer.start()
	ship.takeDmg(DMG)
	ship.apply_central_impulse(_collider.remainder * SHIP_COL_IMPULSE_MOD)
	takeDmg(self, DMG * DMG_TO_SELF_MOD)


func takeDmg(_node_took_dmg:Object, _dmg:int) -> void:
	health -= _dmg
	if health <= 0:  startQueueFreeSequence()
	setWoundedLevel()
	if wounded_level:  startWoundedTweenUp()


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


func startQueueFreeSequence():
	master_move_vector = Vector2()
	master_behavior = 'queue_free_sequence'
	$MasterRotDelayTimer.stop()
	$MasterRotTimer.stop()
	$MasterMoveDelayTimer.stop()
	$MasterMoveTimer.stop()
	collision_layer = 0
	collision_mask = 0
	$Sprite.visible = false
	$LifeEndParticles2D.restart()
	$LifeEndParticlesLifeTimeTimer.start()
	gameplay.initDrop('enemy_01', drop_value, global_position)


####################################################################################################


func _on_MasterRotDelayTimer_timeout():
	master_behavior = 'rot'
	setMasterTargetPosAndVector()
	setAndStartMasterRotTime()
	rot_dir = util.getRandomItemFromArray(ROT_DIRS)


func _on_MasterRotTimer_timeout():
	rotated_enough = true


func _on_MasterMoveDelayTimer_timeout():
	master_behavior = 'move'
	$MasterMoveTimer.wait_time = util.getRandomFloat(MASTER_MOVE_MIN_TIME, MASTER_MOVE_MAX_TIME)
	$MasterMoveTimer.start()


func _on_MasterMoveTimer_timeout():
	master_behavior = 'rot_delay'
	updateIsHomeAndPursue()
	$MasterRotDelayTimer.start()
	master_move_vector = Vector2(0, 0)


func _on_CanDmgShipTimer_timeout():
	can_dmg_ship = true


func _on_WoundedTweenUp_tween_all_completed():
	if wounded_level:  startWoundedTweenDown()


func _on_WoundedTweenDown_tween_all_completed():
	if wounded_level:  startWoundedTweenUp()


func _on_LifeEndParticlesLifeTimeTimer_timeout():
	queue_free()

