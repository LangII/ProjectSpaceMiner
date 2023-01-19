
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')


####################################################################################################


onready var spine = []
onready var segments_map = {}

onready var TAIL_SPIN_SPEED = 4
onready var tail_spin_dir = util.getRandomItemFromArray([+1, -1])

### movement

#onready var SPEED = 80
#onready var INNER_TURN_SHARPNESS = 3.8
onready var SPEED = 60
onready var INNER_TURN_SHARPNESS = 1.5

onready var OUTER_TURN_DEG = 70
#onready var OUTER_TURN_DEG = 80

onready var turn_dir = +1
onready var cur_dir = 90
onready var cur_vector = Vector2(0, SPEED)

### segment functionality
""" TODO:  SEGMENT_COUNT needs to preset the number of 'Body' segments in Enemy. """
onready var SEGMENT_COUNT = 6
onready var SEGMENT_DIAMETER = 20
onready var TAIL_DIAMETER = 10

onready var SPEED_TO_DIST_MODIFIER = 60.0
#onready var SPEED_TO_DIST_MODIFIER = 150.0

onready var SPINE_TO_SPINE_DIST = null
onready var SEGMENT_TO_SEGMENT_SPINE_COUNT = null
onready var SEGMENT_TO_TAIL_SPINE_COUNT = null
onready var TOTAL_SPINE_COUNT = null

onready var target = Vector2(620, 1000)

onready var dist_to_target = 0.0
onready var prev_dist_to_target = 0.0
onready var angle_to_target = 0.0
onready var prev_angle_to_target = 0.0
onready var angle_to_target_is_expanding = null
onready var is_approaching_target = null

#onready var NEW_TARGET_SENS_DIST_MIN = 20
onready var NEW_TARGET_SENS_DIST_MIN = 40

onready var NEW_TARGET_DIST_MIN = 200
onready var NEW_TARGET_DIST_MAX = 400

onready var is_touching_wall = false
onready var prev_is_touching_wall = false
onready var can_get_new_target_from_col = true


####################################################################################################


func _ready() -> void:
	
	initSpine()
	
	initSegmentsMap()
	
	moveSegmentsToIgnored()


func _process(_delta:float) -> void:
	
	updateCurDir()
	
	updateCurVector()
	
	var col = move_and_collide(cur_vector * _delta, false)
	
#	prev_is_touching_wall = is_touching_wall
	
	is_touching_wall = false
	
	if col:
		
#        print("col = ", col)
		
		if col.collider.name == 'TileMap':
			
#            print("col.normal = ", col.normal)
			
			is_touching_wall = true
			
#            cur_vector = cur_vector.bounce(col.normal)
			
#            target = Vector2(600, 450)
			
			if can_get_new_target_from_col:
				
				can_get_new_target_from_col = false
				$CanGetNewTargetFromColTimer.start()

				genNewTargetFromCol(col)
	
	rotation_degrees = cur_dir
	
	updateSpine()
	
	moveSegmentsAlongSpine()
	
	spinTail()
	
	updateDistsToTarget()
	
	updateAnglesToTarget()
	
	updateIsApproachingTarget()
	
	updateAngleToTargetIsExpanding()
	
#	if is_touching_wall and angle_to_target > OUTER_TURN_DEG:  SPEED = 0
#	else:  SPEED = 60
	
#    print("is_approaching_target = ", is_approaching_target)
	
	if not is_touching_wall and is_approaching_target and angle_to_target_is_expanding and angle_to_target > OUTER_TURN_DEG:
		changeTurnDir()
	
	if dist_to_target <= NEW_TARGET_SENS_DIST_MIN:
		
#        print("IS HAPPENING!!!")
		
		genNewTarget()


####################################################################################################


func initSpine() -> void:
	SPINE_TO_SPINE_DIST = SPEED / SPEED_TO_DIST_MODIFIER
	SEGMENT_TO_SEGMENT_SPINE_COUNT = int(SEGMENT_DIAMETER / SPINE_TO_SPINE_DIST) + 1
	SEGMENT_TO_TAIL_SPINE_COUNT = int(((SEGMENT_DIAMETER / 2) + (TAIL_DIAMETER / 2)) / SPINE_TO_SPINE_DIST) + 1
	TOTAL_SPINE_COUNT = (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) + SEGMENT_TO_TAIL_SPINE_COUNT
	for i in TOTAL_SPINE_COUNT:  spine += [global_position]


func initSegmentsMap() -> void:
	
	var segment_names = []
	for child in get_children():
		if child.name.begins_with('Body'):  segment_names += [child.name]
	
	var segment_lag = 0  # without "lag", the segments will naturally space themselves out a little
	for segment_name in segment_names:
		var segment_num = int(segment_name.replace('Body', ''))
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


func updateSpine() -> void:
	spine.push_front(global_position)
	spine.pop_back()


func moveSegmentsAlongSpine() -> void:
	for segment_name in segments_map.keys():
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
	
	""" gen new target within hard coded limits """
#    target = Vector2(util.getRandomInt(400, 600), util.getRandomInt(100, 400))

	""" gen new target at random angle at NEW_TARGET_DIST_MAX dist from cur pos """
	var target_dist = util.getRandomInt(NEW_TARGET_DIST_MIN, NEW_TARGET_DIST_MAX)
	var target_vector = Vector2(target_dist, 0).rotated(deg2rad(util.getRandomInt(0, 360)))
	target = global_position + target_vector


func genNewTargetFromCol(col:KinematicCollision2D) -> void:
#    var dist_to_new_target = global_position.distance_to(target)
#    var angle_to_new_target = util.convAngleTo360Range(rad2deg(cur_vector.bounce(col.normal).angle()))

#    var angle_to_new_target = util.convAngleTo360Range(rad2deg(col.normal.angle()))
#    print("\nangle_to_new_target = ", angle_to_new_target)
#    var vector_to_new_target = Vector2(NEW_TARGET_DIST_MAX, 0).rotated(deg2rad(angle_to_new_target))
#    print("vector_to_new_target = ", vector_to_new_target)
#    target = global_position + vector_to_new_target
#    print("target = ", target)

#    var old_vector = global_position.direction_to(target)
#    var new_vector = old_vector.bounce(col.normal)
#    target = global_position + Vector2(util.getRandomInt(NEW_TARGET_DIST_MIN, NEW_TARGET_DIST_MAX), 0).rotated(new_vector.angle())
	
	var new_target_dist = util.getRandomInt(NEW_TARGET_DIST_MIN, NEW_TARGET_DIST_MAX)
	var new_target_angle_mod = util.getRandomInt(-10, 10)
	target = global_position + Vector2(new_target_dist, 0).rotated(
#        col.normal.angle() + deg2rad(new_target_angle_mod)
		col.normal.angle()
	)

#    print("\nglobal_position = ", global_position)
#    print("target =            ", target)

	print("\rad2deg(ncol.normal.angle()) = ", rad2deg(col.normal.angle()))


"""
2023-01-18
TURNOVER NOTES:
- I think I fixed the problem of the enemy getting caught in an infinite loop by adjust
NEW_TARGET_SENS_DIST_MIN.
- When genNewTarget() due to collision, need to include collision reflection in the genNewTarget()
calculation.
- Need to make tail a little bigger.
"""






func _on_CanGetNewTargetFromColTimer_timeout():

	can_get_new_target_from_col = true
