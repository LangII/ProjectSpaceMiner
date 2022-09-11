
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')


####################################################################################################


onready var spine = []
onready var segments_map = {}

onready var TAIL_SPIN_SPEED = 3
onready var tail_spin_dir = util.getRandomItemFromArray([+1, -1])

### movement
onready var SPEED = 120
onready var TURN_SHARPNESS = 3.5
onready var turn_dir = +1
onready var cur_dir = 90
onready var cur_vector = Vector2(0, SPEED)

### segment functionality
""" TODO:  SEGMENT_COUNT needs to preset the number of 'Body' segments in Enemy. """
onready var SEGMENT_COUNT = 6
onready var SEGMENT_DIAMETER = 20
onready var TAIL_DIAMETER = 10
onready var SPEED_TO_DIST_MODIFIER = 65.0
onready var SPINE_TO_SPINE_DIST = null
onready var SEGMENT_TO_SEGMENT_SPINE_COUNT = null
onready var SEGMENT_TO_TAIL_SPINE_COUNT = null
onready var TOTAL_SPINE_COUNT = null


####################################################################################################


func _ready() -> void:
    
    initSpine()
    
    initSegmentsMap()
    
    moveSegmentsToIgnored()


func _process(_delta:float) -> void:
    
    updateCurDir()
    var col = move_and_collide(getCurVector() * _delta, false)
    
    rotation_degrees = cur_dir
    
    updateSpine()
    
    moveSegmentsAlongSpine()
    
    spinTail()


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
    
    var segment_lag = 0  # without lag, the segments will naturally space themselves out a little
    for segment_name in segment_names:
        var segment_num = int(segment_name.replace('Body', ''))
        var spine_i = (SEGMENT_TO_SEGMENT_SPINE_COUNT * segment_num) - 1 - segment_lag
        segments_map[segment_name] = {'spine_i': spine_i, 'node': get_node(segment_name)}
        segment_lag += 1
    
    var tail_spine_i = (
        (SEGMENT_TO_SEGMENT_SPINE_COUNT * SEGMENT_COUNT) +
        SEGMENT_TO_TAIL_SPINE_COUNT - 1 - segment_lag
    )
    segments_map['Tail'] = {'spine_i': tail_spine_i, 'node': get_node('Tail')}


func moveSegmentsToIgnored() -> void:
    for segment_name in segments_map.keys():
        var segment_node = get_node(segment_name)
        remove_child(segment_node)
        $Ignored.add_child(segment_node)


func updateCurDir() -> void:
    cur_dir = cur_dir + (TURN_SHARPNESS * turn_dir)
    var dec = cur_dir - int(cur_dir)
    cur_dir = (int(cur_dir) % 360) + dec


func getCurVector() -> Vector2:
    return Vector2(0, -SPEED).rotated(deg2rad(cur_dir))


func updateSpine() -> void:
    spine.push_front(global_position)
    spine.pop_back()


func moveSegmentsAlongSpine() -> void:
    for segment_name in segments_map.keys():
        var segment_node = segments_map[segment_name]['node']
        var new_pos = spine[segments_map[segment_name]['spine_i']]
        segment_node.global_position = new_pos


func spinTail() -> void:
    $Ignored/Tail/TailImg.rotation_degrees += TAIL_SPIN_SPEED * tail_spin_dir



