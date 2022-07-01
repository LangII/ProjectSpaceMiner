
extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')

var HOME_POS = Vector2()
var HOME_RADIUS = 0.0

var ROT_DIRS = ['left', 'right']
var ROT_SPEED = 4.0
var MOVE_SPEED = 150.0

var AGGRESSIVE_DIST_RANGE = 200.0

var TARGET_ANGLE_RANGE = 10.0

var MASTER_ROT_DELAY_TIME = 0.2
var MASTER_ROT_MIN_TIME = 0.5
var MASTER_ROT_MAX_TIME = 2.0
var MASTER_MOVE_DELAY_TIME = 0.2
var MASTER_MOVE_MIN_TIME = 0.5
var MASTER_MOVE_MAX_TIME = 1.5

var MAX_HEALTH = 20.0

var DMG = 10.0
var DMG_TO_SELF_MOD = 0.5

var CAN_DMG_SHIP_DELAY = 0.5
var SHIP_COL_IMPULSE_MOD = 80.0
var can_dmg_ship = true

var master_behavior = ''  # ['rot_delay', 'rot', 'move_delay', 'move']
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


####################################################################################################


func _ready():
    
    master_behavior = 'rot_delay'
    
    target_behavior = 'patrol'
    
    $AggressiveRay.cast_to = Vector2(0, -AGGRESSIVE_DIST_RANGE)
    
    $MasterRotDelayTimer.wait_time = MASTER_ROT_DELAY_TIME
    $MasterMoveDelayTimer.wait_time = MASTER_MOVE_DELAY_TIME
    
    $MasterRotDelayTimer.start()
    
    $CanDmgShipTimer.wait_time = CAN_DMG_SHIP_DELAY
    
    rot_dir = util.getRandomItemFromArray(ROT_DIRS)
    
    setMasterTargetPosAndVector()
    setAndStartMasterRotTime()


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
    takeDmg(DMG * DMG_TO_SELF_MOD)


func takeDmg(_dmg):
    health -= _dmg
    if health <= 0:  queue_free()


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


































