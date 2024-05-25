
"""
-------------------
LOW PRIORITY TO DOS
-------------------

2023-02-05

- From split()...

	- Front Enemy02 should keep old Enemy02's target.  It does not.  After split(), both front and
	back Enemy02s make dramatic turns to pursue new targets.

2024-01-31
look into having LifeEndParticles2D like Enemy01

-----
NOTES
-----

SEGMENT DIES BEHAVIOR
	IF tail dies THEN all dies
	IF 0 segments:
		IF head dies THEN all dies
	IF 1 segment:
		IF head dies THEN only segment dies
		IF only segment dies THEN only segment dies
	IF 2 or more segments:
		IF head dies THEN first segment dies
		IF first segment dies THEN first segment dies
		IF last segment dies THEN last segment dies
		IF any other segment dies THEN that segment dies AND split
"""

extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var _enemies_ = get_node('/root/Main/Gameplay/Enemies')
onready var ship = get_node('/root/Main/Gameplay/Ship')

onready var segment_scn = preload('res://scenes/Enemy02Segment.tscn')
onready var enemy02 = load('res://scenes/Enemy02.tscn')


####################################################################################################


onready var spine = []
onready var segments_map = {}

onready var TAIL_SPIN_SPEED = 5
onready var tail_spin_dir = util.getRandomItemFromArray([+1, -1])

onready var SEGMENT_COUNT_MIN = 0
onready var SEGMENT_COUNT_MAX = 21

onready var SPEED_MIN = 100
onready var SPEED_MAX = 60

"""
2023-07-04
- Need to look into why changing these speed vars causes a crash from a split due to some kind of
misalignment with the spine (likely has to do with the init() and spine generation).
"""
#onready var SPEED_MIN = 60
#onready var SPEED_MAX = 40

onready var INNER_TURN_SHARPNESS_MIN = 2.5
onready var INNER_TURN_SHARPNESS_MAX = 1.5
onready var SEGMENT_COUNT = null
onready var SPEED = null
onready var INNER_TURN_SHARPNESS = null

onready var SPEED_TO_DIST_MODIFIER = 60.0

onready var OUTER_TURN_DEG = 70

onready var turn_dir = +1
onready var cur_dir = 90
onready var cur_vector = Vector2()

onready var SEGMENT_DIAMETER = 20
onready var TAIL_DIAMETER = 16

onready var SPINE_TO_SPINE_DIST = null
onready var SEGMENT_TO_SEGMENT_SPINE_COUNT = null
onready var SEGMENT_TO_TAIL_SPINE_COUNT = null
onready var TOTAL_SPINE_COUNT = null

onready var target = Vector2()

onready var dist_to_target = 0.0
onready var prev_dist_to_target = 0.0
onready var angle_to_target = 0.0
onready var prev_angle_to_target = 0.0
onready var angle_to_target_is_expanding = null
onready var is_approaching_target = null

### if this value is too low (20 gave me problems) then enemy02 sometimes ends in an infinite
### movement loop
onready var GEN_NEW_TARGET_WITHIN_DIST = 40

onready var NEW_TARGET_DIST_MIN = 200
onready var NEW_TARGET_DIST_MAX = 400

onready var is_touching_wall = false
onready var can_get_new_target_from_col = true

onready var CAN_GEN_NEW_TARGET_FROM_COL_DELAY = 2

onready var COL_NEW_TARGET_ANGLE_EXPANSION = 15

onready var collision = null

onready var SEGMENT_MAX_HEALTH = 80.0

### WOUNDED_MAP is not 100% dynamic.  To add additional levels, you'll have to add additional
### wounded tweens.
onready var WOUNDED_MAP = {
	'high': {'min': 0.0, 'max': 0.25, 'speed': 0.25},
	'low': {'min': 0.25, 'max': 0.5, 'speed': 1.0}
}
onready var WOUNDED_COLOR = Color(1, 0.4, 0.4, 1)  # red(ish)

onready var HAS_TAKEN_DMG = false

onready var segments_data = {}

onready var LOWEST_SEGMENT_NAME = ''
onready var HIGHEST_SEGMENT_NAME = ''

onready var MIN_DIST_TO_SHIP_TO_TARGET = 1_000.0

onready var CAN_DMG_SHIP_DELAY = 0.5
onready var can_dmg_ship = true
onready var DMG = 20.0
onready var DMG_TO_SELF_MOD = 0.5

#onready var SHIP_COL_IMPULSE_MOD = 80.0
onready var SHIP_COL_IMPULSE_MOD = 20.0


####################################################################################################


func _ready() -> void:
	
	pass


func init(
	_segment_count:int, _from_split:bool=false, _spine:Array=[], _segments_data:Dictionary={}
) -> void:
	
	updateVarsFromSegmentCount(_segment_count)
	
	initSpine()
	
	copySegments()
	
	initSegmentsMap()
	
	$CanGenNewTargetFromColTimer.wait_time = CAN_GEN_NEW_TARGET_FROM_COL_DELAY
	
	genNewTarget()
	
	if _from_split:
		
		spine = _spine
		
		handleSegmentsDataFromSplitInit(_segments_data)
	
	setLowestHighestSegmentNames('init')
	
	$CanDmgShipTimer.wait_time = CAN_DMG_SHIP_DELAY


func _process(_delta:float) -> void:
	
	updateCurDir()
	
	updateCurVector()
	
	collision = move_and_collide(cur_vector * _delta, false)
	
	handleCollision(collision)
	
	rotation_degrees = cur_dir
	
	updateSpine()
	
	moveSegmentsAlongSpine()
	
	spinTail()
	
	updateDistsToTarget()
	
	updateAnglesToTarget()
	
	updateIsApproachingTarget()
	
	updateAngleToTargetIsExpanding()
	
	if (
		not is_touching_wall and is_approaching_target and
		angle_to_target_is_expanding and angle_to_target > OUTER_TURN_DEG
	):  changeTurnDir()
	
	if dist_to_target <= GEN_NEW_TARGET_WITHIN_DIST:  genNewTarget()


####################################################################################################


func updateVarsFromSegmentCount(_segment_count:int) -> void:
	if _segment_count < SEGMENT_COUNT_MIN or _segment_count > SEGMENT_COUNT_MAX:
		util.throwError(
			"Enemy02.updateVarsFromSegmentCount() arg _segment_count must be between %s and %s " %
			[SEGMENT_COUNT_MIN, SEGMENT_COUNT_MAX] + " inclusively."
		)
	SEGMENT_COUNT = _segment_count
	updateSpeedAndInnerTurnSharpness()


func initSpine() -> void:
	SPINE_TO_SPINE_DIST = SPEED / SPEED_TO_DIST_MODIFIER
	SEGMENT_TO_SEGMENT_SPINE_COUNT = int(SEGMENT_DIAMETER / SPINE_TO_SPINE_DIST) + 1
	SEGMENT_TO_TAIL_SPINE_COUNT = int(((SEGMENT_DIAMETER / 2) + (TAIL_DIAMETER / 2)) / SPINE_TO_SPINE_DIST) + 1
	TOTAL_SPINE_COUNT = (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) + SEGMENT_TO_TAIL_SPINE_COUNT
	for i in TOTAL_SPINE_COUNT:  spine += [global_position]


func copySegments() -> void:
	segments_data['Head'] = {
		'health': SEGMENT_MAX_HEALTH, 'wounded_level': null, 'col_node': self, 'img_node': $HeadImg
	}
	for i in range(SEGMENT_COUNT, 0, -1):
		var segment = segment_scn.instance()
		segment.name = 'Segment%02d' % [i]
		segment.get_node('SegmentImg').name = 'Segment%02dImg' % [i]
		add_child_below_node($HeadImg, segment)
		segments_data[segment.name] = {
			'health': SEGMENT_MAX_HEALTH, 'wounded_level': null, 'col_node': segment,
			'img_node': segment.get_node('Segment%02dImg' % [i])
		}
	segments_data['Tail'] = {
		'health': SEGMENT_MAX_HEALTH, 'wounded_level': null, 'col_node': $Tail,
		'img_node': $Tail/TailImg
	}


func initSegmentsMap() -> void:
	var segment_names = []
	for child in get_children():
		if child.name.begins_with('Segment'):  segment_names += [child.name]
	var segment_lag = 0  # without "lag", the segments will naturally space themselves out a little
	for segment_name in segment_names:
		var segment_num = int(segment_name.replace('Segment', ''))
		segments_map[segment_name] = {
			'spine_i': (SEGMENT_TO_SEGMENT_SPINE_COUNT * segment_num) - 1 - segment_lag,
			'node': get_node(segment_name)
		}
		segment_lag += 1
	segments_map['Tail'] = {
		'spine_i': (
			(SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) +
			SEGMENT_TO_TAIL_SPINE_COUNT - 1 - segment_lag
		),
		'node': get_node('Tail')
	}


func handleSegmentsDataFromSplitInit(_segments_data:Dictionary) -> void:
	for segment_name in _segments_data.keys():
		# Only transfer 'health' and 'wounded_level' from _segments_data.  Node ref DO NOT get transfered.
		segments_data[segment_name]['health'] = _segments_data[segment_name]['health']
		segments_data[segment_name]['wounded_level'] = _segments_data[segment_name]['wounded_level']
		if segments_data[segment_name]['health'] < SEGMENT_MAX_HEALTH:  HAS_TAKEN_DMG = true
	if HAS_TAKEN_DMG:
		startWoundedTweenHighUp()
		startWoundedTweenLowUp()


func setLowestHighestSegmentNames(_temp_from:String) -> void:
	var segment_names = []
	for segment_name in segments_data.keys():
		if not segment_name in ['Head', 'Tail']:
			segment_names += [segment_name]
	LOWEST_SEGMENT_NAME = segment_names.min()
	HIGHEST_SEGMENT_NAME = segment_names.max()


####################################################################################################


func updateSpeedAndInnerTurnSharpness() -> void:
	SPEED = util.normalize(
		SEGMENT_COUNT, SEGMENT_COUNT_MIN, SEGMENT_COUNT_MAX, SPEED_MIN, SPEED_MAX
	)
	INNER_TURN_SHARPNESS = util.normalize(
		SEGMENT_COUNT, SEGMENT_COUNT_MIN, SEGMENT_COUNT_MAX, INNER_TURN_SHARPNESS_MIN,
		INNER_TURN_SHARPNESS_MAX
	)


func updateCurDir() -> void:
	cur_dir = cur_dir + (INNER_TURN_SHARPNESS * turn_dir)
	var dec = cur_dir - int(cur_dir)
	cur_dir = (int(cur_dir) % 360) + dec


func updateCurVector() -> void:
	cur_vector = Vector2(0, -SPEED).rotated(deg2rad(cur_dir))


func handleCollision(_col:KinematicCollision2D) -> void:
	is_touching_wall = false
	if not _col:  return
	match _col.collider.name:
		'TileMap':
			is_touching_wall = true
			if can_get_new_target_from_col:
				can_get_new_target_from_col = false
				$CanGenNewTargetFromColTimer.start()
				genNewTargetFromCol(_col)
		'Ship':
			if not can_dmg_ship:  return
			can_dmg_ship = false
			$CanDmgShipTimer.start()
			ship.takeDmg(DMG)
#			ship.apply_central_impulse(_col.remainder * SHIP_COL_IMPULSE_MOD)
			takeDmg(DMG * DMG_TO_SELF_MOD, self)
			gameplay.setEnemyColParticles(_col.position)


func updateSpine() -> void:
	spine.push_front(global_position)
	spine.pop_back()


func moveSegmentsAlongSpine() -> void:
	for segment_name in segments_map.keys():
		segments_map[segment_name]['node'].global_position = spine[segments_map[segment_name]['spine_i']]


func spinTail() -> void:
	$Tail/TailImg.rotation_degrees += TAIL_SPIN_SPEED * tail_spin_dir


####################################################################################################


func updateDistsToTarget() -> void:
	prev_dist_to_target = dist_to_target
	dist_to_target = spine[0].distance_to(target)


func updateAnglesToTarget() -> void:
	prev_angle_to_target = angle_to_target
	angle_to_target = rad2deg(abs((target - spine[1]).angle_to(spine[0] - spine[1])))


func updateIsApproachingTarget() -> void:
	is_approaching_target = true if dist_to_target < prev_dist_to_target else false


func updateAngleToTargetIsExpanding() -> void:
	angle_to_target_is_expanding = true if angle_to_target > prev_angle_to_target else false


func changeTurnDir() -> void:
	turn_dir *= -1


func genNewTarget() -> void:
	var target_dist = util.getRandomInt(NEW_TARGET_DIST_MIN, NEW_TARGET_DIST_MAX)
	var target_angle = 0.0
	var dist_to_ship = global_position.distance_to(ship.global_position)
	if dist_to_ship <= MIN_DIST_TO_SHIP_TO_TARGET:
		target_angle = (ship.global_position - global_position).angle()
	else:
		target_angle = deg2rad(util.getRandomInt(0, 360))
	target = global_position + Vector2(target_dist, 0).rotated(target_angle)


func genNewTargetFromCol(col:KinematicCollision2D) -> void:
	var target_dist = util.getRandomInt(NEW_TARGET_DIST_MIN, NEW_TARGET_DIST_MAX)
	var col_normal = rad2deg(col.normal.angle())
	var target_rot = util.getRandomInt(
		col_normal - COL_NEW_TARGET_ANGLE_EXPANSION,
		col_normal + COL_NEW_TARGET_ANGLE_EXPANSION
	)
	target = global_position + Vector2(target_dist, 0).rotated(target_rot)


####################################################################################################


func takeDmg(_dmg:int, _node_took_dmg:Object):
	HAS_TAKEN_DMG = true
	var segment_name = getSegmentNameFromSegmentObj(_node_took_dmg)
	
	# A VERY DIRTY FIX!!!  PLEASE RETURN TO AND FIX THIS FIX!!!
	# this problem is triggered when a missle kills too many segments at the same time
	if not segment_name in segments_data.keys():  return
	
	# apply damage
	segments_data[segment_name]['health'] -= _dmg
	setWoundedLevels(segment_name)
	startWoundedTweenHighUp()
	startWoundedTweenLowUp()
	# handle "dead" segments
	if segments_data[segment_name]['health'] <= 0:
		if segment_name == 'Tail':  tailDies()
		elif SEGMENT_COUNT == 0:
			if segment_name == 'Head':  tailDies()
		elif SEGMENT_COUNT == 1:
			if segment_name == 'Head':  headDies()
			elif segment_name == LOWEST_SEGMENT_NAME:  headDies()
		elif SEGMENT_COUNT >= 2:
			if segment_name == 'Head':  headDies()
			elif segment_name == LOWEST_SEGMENT_NAME:  headDies()
			elif segment_name == HIGHEST_SEGMENT_NAME:  lastSegmentDies()
			else:  split(segment_name)


func getSegmentNameFromSegmentObj(_segment_obj:Object) -> String:
	var segment_name_ = ''
	var obj_name = _segment_obj.name
	if obj_name.begins_with('Segment'):											segment_name_ = obj_name
	elif (obj_name.begins_with('Enemy02') or obj_name.begins_with('@Enemy02')):	segment_name_ = 'Head'
	elif obj_name == 'Tail':													segment_name_ = 'Tail'
	return segment_name_


func startWoundedTweenHighUp() -> void:
	if not HAS_TAKEN_DMG:  return
	for segment_name in segments_data.keys():
		var wounded_level = segments_data[segment_name]['wounded_level']
		if wounded_level != 'high':  continue
		$WoundedTweenHighUp.interpolate_property(
			segments_data[segment_name]['img_node'], 'modulate', Color(1, 1, 1, 1), WOUNDED_COLOR,
			WOUNDED_MAP[wounded_level]['speed'], 0, 1
		)
	$WoundedTweenHighUp.start()


func startWoundedTweenHighDown():
	if not HAS_TAKEN_DMG:  return
	for segment_name in segments_data.keys():
		var wounded_level = segments_data[segment_name]['wounded_level']
		if wounded_level != 'high':  continue
		$WoundedTweenHighDown.interpolate_property(
			segments_data[segment_name]['img_node'], 'modulate', WOUNDED_COLOR, Color(1, 1, 1, 1),
			WOUNDED_MAP[wounded_level]['speed'], 0, 1
		)
	$WoundedTweenHighDown.start()


func startWoundedTweenLowUp() -> void:
	if not HAS_TAKEN_DMG:  return
	for segment_name in segments_data.keys():
		var wounded_level = segments_data[segment_name]['wounded_level']
		if wounded_level != 'low':  continue
		$WoundedTweenLowUp.interpolate_property(
			segments_data[segment_name]['img_node'], 'modulate', Color(1, 1, 1, 1), WOUNDED_COLOR,
			WOUNDED_MAP[wounded_level]['speed'], 0, 1
		)
	$WoundedTweenLowUp.start()


func startWoundedTweenLowDown():
	if not HAS_TAKEN_DMG:  return
	for segment_name in segments_data.keys():
		var wounded_level = segments_data[segment_name]['wounded_level']
		if wounded_level != 'low':  continue
		$WoundedTweenLowDown.interpolate_property(
			segments_data[segment_name]['img_node'], 'modulate', WOUNDED_COLOR, Color(1, 1, 1, 1),
			WOUNDED_MAP[wounded_level]['speed'], 0, 1
		)
	$WoundedTweenLowDown.start()


func setWoundedLevels(_segment_name:String) -> void:
	for level in WOUNDED_MAP.keys():
		var health = segments_data[_segment_name]['health']
		var health_is_gt_min_wounded_level = health > SEGMENT_MAX_HEALTH * WOUNDED_MAP[level]['min']
		var health_is_lte_max_wounded_level = health <= SEGMENT_MAX_HEALTH * WOUNDED_MAP[level]['max']
		if health_is_gt_min_wounded_level and health_is_lte_max_wounded_level:
			segments_data[_segment_name]['wounded_level'] = level
			return


func tailDies() -> void:
	for segment_name in segments_map.keys():
		var drop_pos = spine[segments_map[segment_name]['spine_i']]
		var drop_name = ''
		if segment_name == 'Tail':  drop_name = 'enemy_02_c'
		else:  drop_name = 'enemy_02_b'
		gameplay.initDrop(drop_name, 1, drop_pos)
	gameplay.initDrop('enemy_02_b', 1, global_position)
	var grabbers_pos = global_position + Vector2(10, 0).rotated(deg2rad(cur_dir))
	gameplay.initDrop('enemy_02_a', 1, grabbers_pos)
	queue_free()


func headDies() -> void:
	updatesFromSplit('headDies', int(LOWEST_SEGMENT_NAME.substr(7, 2)) - 1)
	segmentDiesSubSequence()
	gameplay.initDrop('enemy_02_b', 1, global_position)


func lastSegmentDies() -> void:
	# del last segment's data
	SEGMENT_COUNT -= 1
	get_node(HIGHEST_SEGMENT_NAME).queue_free()
	segments_map.erase(HIGHEST_SEGMENT_NAME)
	segments_data.erase(HIGHEST_SEGMENT_NAME)
	# set new Tail spine_i
	var new_tail_spine_i = SEGMENT_TO_TAIL_SPINE_COUNT
	if SEGMENT_COUNT != 0:
		var second_to_last_segment_name = 'Segment%02d' % [int(HIGHEST_SEGMENT_NAME.substr(7, 2)) - 1]
		new_tail_spine_i += segments_map[second_to_last_segment_name]['spine_i']
	segments_map['Tail']['spine_i'] = new_tail_spine_i
	# reset segment names
	setLowestHighestSegmentNames('lastSegmentDies')
	# standard dead segment procedures
	segmentDiesSubSequence()
	gameplay.initDrop('enemy_02_b', 1, spine[segments_map[HIGHEST_SEGMENT_NAME]['spine_i']])


func split(_del_segment_name:String) -> void:
	var del_segment_i = int(_del_segment_name.substr(7, 2))
	# have to collect 'drop_pos' now before updatesFromSplit()
	var drop_pos = spine[segments_map[_del_segment_name]['spine_i']]
	instanceFrontEnemy02FromSplit(_del_segment_name, del_segment_i)
	updatesFromSplit('split', del_segment_i)
	segmentDiesSubSequence()
	gameplay.initDrop('enemy_02_b', 1, drop_pos)


func updatesFromSplit(_temp_from:String, _del_segment_i:int) -> void:
	
	var true_del_segment_i = null
	if _temp_from == 'split':  true_del_segment_i = getTrueDelSegmentI(_del_segment_i)
	elif _temp_from == 'headDies':  true_del_segment_i = 0
		
	SEGMENT_COUNT -= true_del_segment_i + 1
	
	var new_head_segment = 'Segment%02d' % [_del_segment_i + 1]
	
	# Transfer health and wounded data from segment to new head.
	segments_data['Head']['health'] = segments_data[new_head_segment]['health']
	segments_data['Head']['wounded_level'] = segments_data[new_head_segment]['wounded_level']
	
	# Save spine and pos data before making deletions on segments map and data.
	var new_head_spine_i = segments_map[new_head_segment]['spine_i']
	var new_spine = spine.slice(segments_map[new_head_segment]['spine_i'], spine.size())
	var new_head_global_position = spine[segments_map[new_head_segment]['spine_i']]
	
	# Delete "front" section of segments.
	for i in range(int(LOWEST_SEGMENT_NAME.substr(7, 2)), _del_segment_i + 2):
		var segment_name = 'Segment%02d' % [i]
		get_node(segment_name).queue_free()
		segments_map.erase(segment_name)
		segments_data.erase(segment_name)
	
	var buffer_spine = []
	for _i in range(50):
		buffer_spine += [new_spine[-1]]
	
	# Transfer saved spine and pos data to new "back" section of segments.
	for segment_name in segments_map.keys():  segments_map[segment_name]['spine_i'] -= new_head_spine_i
	
	spine = new_spine + buffer_spine
	
	global_position = new_head_global_position
	
	setLowestHighestSegmentNames('updatesFromSplit')
	
	genNewTarget()


func getTrueDelSegmentI(_del_segment_i:int) -> int:
	"""
	true_del_segment_i is needed to fix a stupid mistake.  del_segment_name is the name of the
	segment being deleted.  So, del_segment_i is the suffix number of the segment name.  Well,
	del_segment_i was used to represent the number of segments from the Head the delete segment was.
	This was a mistake because one of the Enemy02 resulting from a split() has a set of segment
	names that do not start with '01'.  So, in that case del_segment_i would not represent the
	number of segments from the Head.  To conclude, true_del_segment_i represents the number of
	segments from the head.
	"""
	var true_del_segment_i_ = null
	var del_segment_name = 'Segment%02d' % [_del_segment_i]
	var true_segment_names = segments_data.keys().slice(1, -2)
	true_segment_names.sort()
	var true_segment_names_i = 1
	for true_segment_name in true_segment_names:
		if del_segment_name == true_segment_name:
			true_del_segment_i_ = true_segment_names_i
			break
		true_segment_names_i += 1
	if not true_del_segment_i_:  util.throwError("\n\\_(**)_/\n")
	return true_del_segment_i_


func segmentDiesSubSequence() -> void:
	$WoundedTweenHighUp.remove_all()
	$WoundedTweenHighDown.remove_all()
	$WoundedTweenLowUp.remove_all()
	$WoundedTweenLowDown.remove_all()
	$HeadImg.modulate = Color(1, 1, 1, 1)
	startWoundedTweenHighUp()
	startWoundedTweenLowUp()


func instanceFrontEnemy02FromSplit(_del_segment_name:String, _del_segment_i:int) -> void:
	_del_segment_i = getTrueDelSegmentI(_del_segment_i)
	var new_front_segments_data = {}
	for i in range(int(LOWEST_SEGMENT_NAME.substr(7, 2)), _del_segment_i):
		var segment_name = 'Segment%02d' % [i]
		new_front_segments_data[segment_name] = segments_data[segment_name]
	new_front_segments_data['Head'] = segments_data['Head'].duplicate(true)
	new_front_segments_data['Tail'] = segments_data['Tail']
	gameplay.enemy_gen_logic.genEnemy02(
		global_position, _del_segment_i - 1, true,
		# Giving a large buffer to end of slice for quick and dirty debug.
		spine.slice(0, segments_map[_del_segment_name]['spine_i'] + 200),
		new_front_segments_data
	)


####################################################################################################


func printDmg() -> void:
	print("\n'%s' dmg:" % [name])
	print("\t'Head'     : %s" % [segments_data['Head']['health']])
	var segment_names = segments_data.keys()
	segment_names.sort()
	for segment_name in segment_names:
		if segment_name in ['Head', 'Tail']:  continue
		print("\t'%s': %s" % [segment_name, segments_data[segment_name]['health']])
	print("\t'Tail'     : %s" % [segments_data['Tail']['health']])


func printDebugReview() -> void:
	
	var spine_is = []
	for segment_name in segments_map.keys():  spine_is += [segments_map[segment_name]['spine_i']]
	spine_is.sort()
	var segment_gaps = [spine_is[0]]
	for i in range(len(spine_is)):
		if i + 2 >= len(spine_is):  break
		segment_gaps += [spine_is[i + 1] - spine_is[i]]
	var lowest_segment_spine_i = null
	if LOWEST_SEGMENT_NAME:  lowest_segment_spine_i = segments_map[LOWEST_SEGMENT_NAME]['spine_i']
	var highest_segment_spine_i = null
	if HIGHEST_SEGMENT_NAME:  highest_segment_spine_i = segments_map[HIGHEST_SEGMENT_NAME]['spine_i']
	
	print("\n'%s' debug review:" % [name])
	print("\tSEGMENT_COUNT              = ", SEGMENT_COUNT)
	print("\tLOWEST_SEGMENT_NAME        = ", LOWEST_SEGMENT_NAME)
	print("\tHIGHEST_SEGMENT_NAME       = ", HIGHEST_SEGMENT_NAME)
	print("\tlowest_segment_spine_i     = ", lowest_segment_spine_i)
	print("\thighest_segment_spine_i    = ", highest_segment_spine_i)
	print("\ttail_spine_i               = ", segments_map['Tail']['spine_i'])
	print("\tspine len                  = ", len(spine))
	print("\tspine_is                   = ", spine_is)
	print("\tsegment_gaps               = ", segment_gaps)
	print("\tsegment_gaps avg           = ", util.getAvgFromArray(segment_gaps))
	print("\ttail gap                   = ", segments_map['Tail']['spine_i'] - segments_map[HIGHEST_SEGMENT_NAME]['spine_i'])
	print("\tbuffer segments after tail = ", len(spine) - segments_map['Tail']['spine_i'])


func printFullSegmentsDataNMap() -> void:
	print("\n'%s' segments_data = " % [name], segments_data)
	print("\n'%s' segments_map  = " % [name], segments_map)


####################################################################################################


func _on_CanGenNewTargetFromColTimer_timeout():
	can_get_new_target_from_col = true


func _on_WoundedTweenHighUp_tween_all_completed():
	startWoundedTweenHighDown()


func _on_WoundedTweenHighDown_tween_all_completed():
	startWoundedTweenHighUp()


func _on_WoundedTweenLowUp_tween_all_completed():
	startWoundedTweenLowDown()


func _on_WoundedTweenLowDown_tween_all_completed():
	startWoundedTweenLowUp()


func _on_CanDmgShipTimer_timeout():
	can_dmg_ship = true
















