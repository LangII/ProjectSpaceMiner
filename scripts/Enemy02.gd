
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

onready var SPEED = 60
onready var INNER_TURN_SHARPNESS = 1.5
#onready var SPEED = 80
#onready var INNER_TURN_SHARPNESS = 2.5

onready var OUTER_TURN_DEG = 70

onready var turn_dir = +1
onready var cur_dir = 90
onready var cur_vector = Vector2(0, SPEED)

### segment functionality
""" TODO:  SEGMENT_COUNT needs to preset the number of 'Body' segments in Enemy. """
onready var SEGMENT_COUNT = 6
onready var SEGMENT_DIAMETER = 20
onready var TAIL_DIAMETER = 16

onready var SPEED_TO_DIST_MODIFIER = 60.0

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

#onready var SEGMENT_MAX_HEALTH = 80.0
#onready var health = MAX_HEALTH


####################################################################################################


func _ready() -> void:
	
	pass


func init(_segment_count:int) -> void:
	
	"""
	Need to add a function between initSpine() and initSegmentsMap() that duplicates node
	'Segment01'.  Be sure all children are duplicated too, appropriately rename the duplicates, and
	keep duplicates in correct order.
	"""
	
	SEGMENT_COUNT = _segment_count
	
	initSpine()
	
	copySegments(_segment_count)
	
	initSegmentsMap()
	
	moveSegmentsToIgnored()
	
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


func initSpine() -> void:
	SPINE_TO_SPINE_DIST = SPEED / SPEED_TO_DIST_MODIFIER
	SEGMENT_TO_SEGMENT_SPINE_COUNT = int(SEGMENT_DIAMETER / SPINE_TO_SPINE_DIST) + 1
	SEGMENT_TO_TAIL_SPINE_COUNT = int(((SEGMENT_DIAMETER / 2) + (TAIL_DIAMETER / 2)) / SPINE_TO_SPINE_DIST) + 1
	TOTAL_SPINE_COUNT = (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) + SEGMENT_TO_TAIL_SPINE_COUNT
	
	print("\nTOTAL_SPINE_COUNT = ", TOTAL_SPINE_COUNT)
	
	for i in TOTAL_SPINE_COUNT:  spine += [global_position]


func copySegments(_segment_count:int) -> void:
	
#	print("\nsegment_scn = ", segment_scn)
	
	SEGMENT_COUNT = _segment_count
	
	for i in range(SEGMENT_COUNT, 0, -1):
#		print("i = ", i)
#		i += 1
		
		var area_2d_name = 'Segment%02d' % [i]
		var sprite_name = 'Segment%02dImg' % [i]
#		print("\narea_2d_name = ", area_2d_name)
#		print("sprite_name = ", sprite_name)
		
		var segment = segment_scn.instance()
		segment.name = area_2d_name
		segment.get_node('SegmentImg').name = sprite_name
		
		add_child_below_node($HeadImg, segment)
		


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
	
#	print("\nsegments_map = ", segments_map)
	
	for segment_name in segments_map.keys():
		
#		print("\nsegment_name = ", segment_name)
		
		segments_map[segment_name]['node'].global_position = spine[segments_map[segment_name]['spine_i']]


func spinTail() -> void:
	$Ignored/Tail/TailImg.rotation_degrees += TAIL_SPIN_SPEED * tail_spin_dir


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


func _on_CanGenNewTargetFromColTimer_timeout():
	can_get_new_target_from_col = true






"""
2023-01-21
TURNOVER NOTES:

- Need to create an init() to declare and generate number of segments.

- Need to have enemy02 track ship.  When genNewTarget(), if distance to ship is less than VAR, make
new target be global position of ship.  Also need to make sure that when distance to ship is less
than VAR, that there is no TileMap between enemy02 and ship.

- Start having interactions between ship and enemy02.  When enemy02 collides with ship, ship takes
damage and gets knocked back.  When bullets collide with enemy02, enemy02 takes damage.

- Need to figure out enemy02's health.  Each segment will have its own health.  As each segment is
damaged, the individual segments will start flashing red to indicate damage taken.  If the tail is
hit, the head takes damage.  If the head dies, the enemy02 dies.  If a segment dies, enemy02 splits
into 2 enemy02s...  Need to develop mechanic of split.

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






