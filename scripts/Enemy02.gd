
extends KinematicBody2D
#extends Area2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')

onready var TAIL_SPIN_SPEED = 2

onready var spine = []
onready var segments = {}

onready var tail_spin_dir = util.getRandomItemFromArray([+1, -1])

onready var turn_dir = +1

onready var SPEED = 100
onready var SPIN = 2.5
onready var cur_dir = 90
onready var cur_vector = Vector2(0, SPEED)

onready var cur_dist = 0.0

onready var new_spine = []
onready var LEN_NEW_SPINE = 500

onready var prev_pos = Vector2(0, 0)

#onready var SPEED_TO_DIST_MODIFIER = 141.9696
onready var SPEED_TO_DIST_MODIFIER = 65.0

onready var SPINE_TO_SPINE_DIST = 0.0

""" TODO:  SEGMENT_COUNT needs to preset the number of 'Body' segments in Enemy. """
onready var SEGMENT_COUNT = 3

onready var SEGMENT_DIAMETER = 20
onready var TAIL_DIAMETER = 10

onready var SEGMENT_TO_SEGMENT_SPINE_COUNT = 0
onready var SEGMENT_TO_TAIL_SPINE_COUNT = 0
onready var TOTAL_SPINE_COUNT = 0

"""
050 = 0.352173 = 141.9756
100 = 0.704376 = 141.9696
150 = 1.064880 = 144.0014
200 = 1.408752 = 141.9696
"""


####################################################################################################


func _ready() -> void:
    
#    pass
    
    SPINE_TO_SPINE_DIST = SPEED / SPEED_TO_DIST_MODIFIER
    print("SPINE_TO_SPINE_DIST = ", SPINE_TO_SPINE_DIST)
    
    prev_pos = global_position
    
#    setSegmentCount()
#    print("SEGMENT_COUNT = ", SEGMENT_COUNT)
    
    initSpine()
    print("spine = ", spine)
    print("len(spine) = ", len(spine))
    
    initSegments()
    print("segments = ", segments)
    
#    moveSegmentsToIgnored()
    
#    for _i in LEN_NEW_SPINE:  new_spine += [Vector2(0, 0)]
    
    
#    print("spine = ", spine)
#    print("segments = ", segments)


func _process(_delta:float) -> void:
    
#    pass
    
    updateCurDir()
    var col = move_and_collide(getCurVector() * _delta, false)
    
    spine.push_front(global_position)
    spine.pop_back()
    
    for segment_name in segments.keys():
#        get_node('Ignored/%s' % [segment_name]).global_position = spine[segments[segment_name]['spine_i']]
        get_node(segment_name).global_position = spine[segments[segment_name]['spine_i']]
    
    
    spinTail()
#
    rotation_degrees = cur_dir
    
#    updateCurDir()
#
#
#    global_position = global_position + getCurVector(_delta)
#
#    cur_dist = spine[0].distance_to(global_position)
    
#    print("(after) global_position = ", global_position)
    
#    updateSpine()
    
#    var new_spine = [] + spine
#    for i in len(spine):
#        if i == 0:  continue
#        if cur_dist <= 1:
#            new_spine[i] = spine[i].move_toward(spine[i - 1], cur_dist)
#    new_spine[0] = global_position
#    spine = [] + new_spine
    
#    for segment_name in segments.keys():
#        var segment = get_node(segment_name)
#        var segment = get_node('Ignored/%s' % [segment_name])
#        segment.global_position = spine[segments[segment_name]['spine_i']]
#        var going_to = spine[segments[segment_name]['spine_i']]
#        var new_pos = segment.global_position.move_toward(going_to, SPEED)
#        segment.global_position = new_pos
    
#    addToNewSpine(global_position)
#
#    var spine_i = getSpineI(0)
#
#    $Ignored/Body01.global_position = spine[spine_i]

"""
TURNOVER NOTES:
    
    - New attempt:
        - Populate 'spine' with 'global_position' every frame.
        - Go through each node on 'spine' and see if it is the correct distance from 'global_position'.
        Then place 'segment' on that 'node'.
"""


####################################################################################################


#func setSegmentCount() -> void:
#    for child in get_children():
#        if child.name.begins_with('Body'):
#            SEGMENT_COUNT += 1


func initSpine() -> void:
    
    var spine_len = 0
    
    var spine_pixel_count = (
        (SEGMENT_DIAMETER / 2) +                # pixels in head
        (SEGMENT_DIAMETER * SEGMENT_COUNT) +    # pixels in segments
        (TAIL_DIAMETER / 2)                     # pixels in tail
    )
    print("spine_pixel_count = ", spine_pixel_count)
    
    SEGMENT_TO_SEGMENT_SPINE_COUNT = int(SEGMENT_DIAMETER / SPINE_TO_SPINE_DIST) + 1
    print("SEGMENT_TO_SEGMENT_SPINE_COUNT = ", SEGMENT_TO_SEGMENT_SPINE_COUNT)
    
    SEGMENT_TO_TAIL_SPINE_COUNT = int(((SEGMENT_DIAMETER / 2) + (TAIL_DIAMETER / 2)) / SPINE_TO_SPINE_DIST) + 1
    print("SEGMENT_TO_TAIL_SPINE_COUNT = ", SEGMENT_TO_TAIL_SPINE_COUNT)
    
    TOTAL_SPINE_COUNT = (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) + SEGMENT_TO_TAIL_SPINE_COUNT
    print("TOTAL_SPINE_COUNT = ", TOTAL_SPINE_COUNT)
    
#    for i in range(global_position.y, $Tail.global_position.y + 1):
    for i in TOTAL_SPINE_COUNT:
#        spine += [Vector2(int(global_position.x), int(i))]
        spine += [global_position]


func initSegments() -> void:
    
#    var segment_names = ['Enemy02']
    var segment_names = []
    for child in get_children():
        if child.name.begins_with('Body'):  segment_names += [child.name]
#    segment_names += ['Tail']
    
#    segments['Enemy02'] = {'spine_i': 0}
    
    var segment_lag = 0
    
    for segment_name in segment_names:
#        var segment_pos = get_node(segment_name).global_position
#        var looking_for = [int(segment_pos.y), int(segment_pos.x)]
#        print("segment_pos = ", segment_pos)
#        var spine_i = spine.find(segment_pos)
        
        var segment_count = int(segment_name.replace('Body', ''))
        var spine_i = (SEGMENT_TO_SEGMENT_SPINE_COUNT * segment_count) - 1 - segment_lag
        segments[segment_name] = {'spine_i': spine_i}
        
        segment_lag += 1
    
    var tail_spine_i = (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) + SEGMENT_TO_TAIL_SPINE_COUNT - 1 - segment_lag
    segments['Tail'] = {'spine_i': tail_spine_i}


func moveSegmentsToIgnored() -> void:
    for segment_name in segments.keys():
#        print("segment_name = ", segment_name)
        var segment_node = get_node(segment_name)
        remove_child(segment_node)
        $Ignored.add_child(segment_node)
#        var pos = spine[segments[segment_name]['spine_i']]
#        segment_node.global_position = Vector2(pos[1], pos[0])


func spinTail() -> void:
#    $Ignored/Tail/TailImg.rotation_degrees += TAIL_SPIN_SPEED * tail_spin_dir
    $Tail/TailImg.rotation_degrees += TAIL_SPIN_SPEED * tail_spin_dir


func updateCurDir() -> void:
    cur_dir = cur_dir + (SPIN * turn_dir)
    var dec = cur_dir - int(cur_dir)
    cur_dir = (int(cur_dir) % 360) + dec


func getCurVector() -> Vector2:
    return Vector2(0, -SPEED).rotated(deg2rad(cur_dir))


func updateSpine() -> void:
#    spine.push_front(getCurVector())
#    spine.push_front(global_position)
    
    var new_pos = spine[0].move_toward(global_position, cur_dist)
    spine.push_front(new_pos)
    
    var new_spine = [] + spine
    for i in len(spine):
        if i == 0:  continue
        if cur_dist <= 1:
            new_spine[i] = spine[i].move_toward(spine[i - 1], cur_dist)
    spine = [] + new_spine
#
#    spine[0] = global_position
    
    spine.pop_back()


func addToNewSpine(_to_add:Vector2) -> void:
    new_spine.push_front(_to_add)
    new_spine.pop_back()


func getSpineI(_start:int) -> int:
    var new_spine_i = -1
    for i in range(len(new_spine)).slice(_start, len(new_spine)):
        if new_spine[i] == Vector2(0, 0):  return new_spine_i
        if new_spine[_start].distance_to(new_spine[i]) > 20:  return i - 1
    return new_spine_i


"""




"""
