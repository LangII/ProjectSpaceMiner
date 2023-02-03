
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')


####################################################################################################


onready var segment_scn = preload('res://scenes/Enemy02Segment.tscn')

onready var spine = []
onready var segments_map = {}

onready var TAIL_SPIN_SPEED = 5
onready var tail_spin_dir = util.getRandomItemFromArray([+1, -1])

onready var SEGMENT_COUNT_LOW = 1
onready var SEGMENT_COUNT_HIGH = 21
onready var SPEED_LOW = 100
onready var SPEED_HIGH = 60
onready var INNER_TURN_SHARPNESS_LOW = 2.5
onready var INNER_TURN_SHARPNESS_HIGH = 1.5

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

""" TODO:  initial target to be randomly generated """
onready var target = Vector2(620, 1000)

onready var dist_to_target = 0.0
onready var prev_dist_to_target = 0.0
onready var angle_to_target = 0.0
onready var prev_angle_to_target = 0.0
onready var angle_to_target_is_expanding = null
onready var is_approaching_target = null

### if this value is too low (20 gave me problems) then enemy02 sometimes ends in an infinite movement loop
onready var GEN_NEW_TARGET_WITHIN_DIST = 40

onready var NEW_TARGET_DIST_MIN = 200
onready var NEW_TARGET_DIST_MAX = 400

onready var is_touching_wall = false
onready var prev_is_touching_wall = false
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
onready var WOUNDED_COLOR = Color(1, 0.4, 0.4, 1)  # red

onready var HAS_TAKEN_DMG = false

onready var segments_data = {}


####################################################################################################


func _ready() -> void:
	
	pass


func init(_segment_count:int, _split_data_pack:Dictionary={}) -> void:
	
	updateVarsFromSegmentCount(_segment_count)
	
	initSpine()
	
	copySegments()
	
	initSegmentsMap()
	
	$CanGenNewTargetFromColTimer.wait_time = CAN_GEN_NEW_TARGET_FROM_COL_DELAY


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
	if _segment_count < SEGMENT_COUNT_LOW or _segment_count > SEGMENT_COUNT_HIGH:
		util.throwError(
			"Enemy02.updateVarsFromSegmentCount() arg _segment_count must be between %s and %s " %
			[SEGMENT_COUNT_LOW, SEGMENT_COUNT_HIGH] + "inclusively."
		)
	SEGMENT_COUNT = _segment_count
	SPEED = util.normalize(
		SEGMENT_COUNT, SEGMENT_COUNT_LOW, SEGMENT_COUNT_HIGH, SPEED_LOW, SPEED_HIGH
	)
	INNER_TURN_SHARPNESS = util.normalize(
		SEGMENT_COUNT, SEGMENT_COUNT_LOW, SEGMENT_COUNT_HIGH, INNER_TURN_SHARPNESS_LOW,
		INNER_TURN_SHARPNESS_HIGH
	)


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


func moveSegmentsToIgnored() -> void:
	for segment_name in segments_map.keys():
		var segment_node = get_node(segment_name)
		remove_child(segment_node)
		$Ignored.add_child(segment_node)


####################################################################################################


func updateCurDir() -> void:
	cur_dir = cur_dir + (INNER_TURN_SHARPNESS * turn_dir)
	var dec = cur_dir - int(cur_dir)
	cur_dir = (int(cur_dir) % 360) + dec


func updateCurVector() -> void:
	cur_vector = Vector2(0, -SPEED).rotated(deg2rad(cur_dir))


func handleCollision(_col:KinematicCollision2D) -> void:
	is_touching_wall = false
	if _col:
		if _col.collider.name == 'TileMap':
			is_touching_wall = true
			if can_get_new_target_from_col:
				can_get_new_target_from_col = false
				$CanGenNewTargetFromColTimer.start()
				genNewTargetFromCol(_col)


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
	var target_angle = deg2rad(util.getRandomInt(0, 360))
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


func takeDmg(_node_took_dmg:Object, _dmg:int) -> void:
	HAS_TAKEN_DMG = true
	var segment_name = ''
	if _node_took_dmg.name.begins_with('Segment'):		segment_name = _node_took_dmg.name
	elif _node_took_dmg.name.begins_with('Enemy02'):	segment_name = 'Head'
	elif _node_took_dmg.name == 'Tail':					segment_name = 'Tail'
	segments_data[segment_name]['health'] -= _dmg
	setWoundedLevels(segment_name)
	startWoundedTweenHighUp()
	startWoundedTweenLowUp()


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
		if (
			(segments_data[_segment_name]['health'] > SEGMENT_MAX_HEALTH * WOUNDED_MAP[level]['min']) and
			(segments_data[_segment_name]['health'] <= SEGMENT_MAX_HEALTH * WOUNDED_MAP[level]['max'])
		):
			segments_data[_segment_name]['wounded_level'] = level
			return


func getSplitDataPack() -> Dictionary:
	var split_data_pack_ = {}
	var spine_ = null
	
	"""
	2023-02-02
	TURNOVER NOTES:
	
	- When Enemy02 splits:
		
		- 2 major things have to happen:
			
			- The old Enemy02 needs to have its Head relocated to just after the split, and the rest
			of its front section needs to be removed.  This will need to include changes to class
			vars like 'spine', 'segments_map', and 'segments_data'.
			
			- The new Enemy02 needs to be spawned by accepting params of 'spine' and segments health.
				
				- Before spawning new Enemy02, old Enemy02 will need to collect and modify the
				correct data for new Enemy02 to use.  This includes:
					
					- modified 'spine'
					- segments location in spine (spine_i)
					- segments health
	"""
	
	return split_data_pack_


func split() -> void:
	
	var new_head = 'Segment04'
	
	var new_head_i = segments_map['Segment04']['spine_i']
	
	var new_spine = spine.slice(segments_map['Segment04']['spine_i'], spine.size())
	
	var new_head_global_position = spine[segments_map['Segment04']['spine_i']]
	
	for segment_name in ['Segment01', 'Segment02', 'Segment03', 'Segment04']:
		
		get_node(segment_name).queue_free()
		
		segments_map.erase(segment_name)
		
		segments_data.erase(segment_name)
	
	for segment_name in segments_map.keys():
		
		segments_map[segment_name]['spine_i'] -= new_head_i
	
	spine = new_spine
	
	global_position = new_head_global_position

	SPEED = util.normalize(
		4, SEGMENT_COUNT_LOW, SEGMENT_COUNT_HIGH, SPEED_LOW, SPEED_HIGH
	)
	INNER_TURN_SHARPNESS = util.normalize(
		4, SEGMENT_COUNT_LOW, SEGMENT_COUNT_HIGH, INNER_TURN_SHARPNESS_LOW,
		INNER_TURN_SHARPNESS_HIGH
	)


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






"""
2023-01-21
TURNOVER NOTES:

- Notes for health mechanics:
	
	- Each Segment has its own individual Health.  In this statement the Head is considered a
	Segment.
	
	- If the Head or the last Segment touching the Tail gets its Health reduced to 0, the number of
	Segments the Enemy has is reduced by 1.
	
	- If a central Segment (not a Head and not the last Segment touching the Tail) gets its Health
	reduced to 0, said central Segment will be eliminated and the Enemy will turn into 2 Enemies.
	
	- The Tail is the Enemy's weak point.  If the Tail is hit, there is the potential of killing the
	entire Enemy.  How much damage is done when the Tail is hit 
"""











