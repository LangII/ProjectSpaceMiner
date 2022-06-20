
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')

var HOME_POS = Vector2()
var HOME_RADIUS = 0.0

var ROT_DIRS = ['left', 'right']
var ROT_SPEED = 2.5
var MOVE_SPEED = 150.0

var AGGRESSIVE_RANGE = 100.0

var TARGET_ANGLE_RANGE = 10.0

var PASSIVE_ROT_DELAY_TIME = 0.2
var PASSIVE_ROT_MIN_TIME = 0.5
var PASSIVE_ROT_MAX_TIME = 2.0
var PASSIVE_MOVE_DELAY_TIME = 0.2
var PASSIVE_MOVE_MIN_TIME = 0.5
var PASSIVE_MOVE_MAX_TIME = 1.5

var behavior = ''

var rot_dir = ''

var passive_move_vector = Vector2()
var rotated_enough = false

var passive_target_pos = Vector2()
var passive_target_vector = Vector2()

var homeless_pos_trail = []


####################################################################################################


func _ready():
    
    behavior = 'passive_rot_delay'
    
    $AggressiveRay.cast_to = Vector2(0, -AGGRESSIVE_RANGE)
    
    $PassiveRotDelayTimer.wait_time = PASSIVE_ROT_DELAY_TIME
    $PassiveMoveDelayTimer.wait_time = PASSIVE_MOVE_DELAY_TIME
    
    $PassiveRotDelayTimer.start()
    
    rot_dir = util.getRandomItemFromArray(ROT_DIRS)
    
    setPassiveTargetPosAndVector()
    setAndStartPassiveRotTime()


func _process(delta):
    
    match behavior:
#
        'passive_rot_delay':  pass
        
        'passive_rot':
            standardRotate()
            if rotated_enough and passiveTargetIsWithinAngularRange():  updateToMoveBehavior()
        
        'passive_move_delay':  pass
        
        'passive_move':
            var col = move_and_collide(passive_move_vector * delta)


####################################################################################################


func setPassiveTargetPosAndVector():
    var pass_target_rot = util.getRandomFloat(0.0, 360.0)
    var pass_target_dist = util.getRandomFloat(0.0, HOME_RADIUS)
    passive_target_pos = HOME_POS + (Vector2(pass_target_dist, 0).rotated(deg2rad(pass_target_rot)))
    passive_target_vector = passive_target_pos - global_position


func setAndStartPassiveRotTime():
    rotated_enough = false
    $PassiveRotTimer.wait_time = util.getRandomFloat(PASSIVE_ROT_MIN_TIME, PASSIVE_ROT_MAX_TIME)
    $PassiveRotTimer.start()


func standardRotate():
    match rot_dir:
        'left':  rotation_degrees -= ROT_SPEED
        'right':  rotation_degrees += ROT_SPEED


func passiveTargetIsWithinAngularRange() -> bool:
    var looking_at_vector = $LookingAtPos.global_position - global_position
    var angle_to_target = rad2deg(looking_at_vector.angle_to(passive_target_vector))
    return abs(angle_to_target) < TARGET_ANGLE_RANGE


func updateToMoveBehavior():
    behavior = 'passive_move_delay'
    var move_angle = global_position.angle_to_point($LookingAtPos.global_position)
    passive_move_vector = Vector2(-MOVE_SPEED, 0).rotated(move_angle)
    $PassiveMoveDelayTimer.start()


####################################################################################################


func _on_PassiveRotDelayTimer_timeout():
    behavior = 'passive_rot'
    setPassiveTargetPosAndVector()
    setAndStartPassiveRotTime()
    rot_dir = util.getRandomItemFromArray(ROT_DIRS)


func _on_PassiveRotTimer_timeout():
    rotated_enough = true


func _on_PassiveMoveDelayTimer_timeout():
    behavior = 'passive_move'
    $PassiveMoveTimer.wait_time = util.getRandomFloat(PASSIVE_MOVE_MIN_TIME, PASSIVE_MOVE_MAX_TIME)
    $PassiveMoveTimer.start()


func _on_PassiveMoveTimer_timeout():
    behavior = 'passive_rot_delay'
    $PassiveRotDelayTimer.start()

























