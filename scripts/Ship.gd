
extends RigidBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var hud = null  # assigned in Hud.gd

onready var tile_map_logic = get_node('/root/Main/TileMapLogic')
onready var tile_map = get_node('/root/Main/TileMap')

onready var projectiles = get_node('/root/Main/Gameplay/Projectiles')
onready var bullet_01 = preload('res://scenes/Bullet01.tscn')

var MOVE_ACC = 250
var MOVE_MAX_SPEED = 180
var MOVE_MAX_SPEED_RESISTANCE = 5

var SPIN_ACC = 2000
var SPIN_MAX_SPEED = 7
var SPIN_MAX_SPEED_RESISTANCE = 10

var TURRET_COOL_DOWN_WAIT_TIME = 0.4

var MAX_TERRAIN_COL_DMG = 2.0
var MAX_HEALTH = 200
var COL_DMG_SPEED_MODIFIER = 0.75
var PHYSICAL_ARMOR = 0.02
var TERRAIN_COL_WAIT_TIME = 0.1
var can_take_terrain_col_dmg = true

var DROP_PICK_UP_RADIUS = 100

var health = MAX_HEALTH

var can_shoot = true

var prev_frame_dir = 0


####################################################################################################


func _ready():
    
    setCameraParams()
    
    $CanShootTimer.wait_time = TURRET_COOL_DOWN_WAIT_TIME
    
    $CanTakeTerrainColDmgTimer.wait_time = TERRAIN_COL_WAIT_TIME
    
    $DropPickUp/CollisionShape2D.shape.radius = DROP_PICK_UP_RADIUS


func _physics_process(_delta):
    
    $Turret.look_at(get_global_mouse_position())
    $Turret.rotate(deg2rad(90))
    
    if Input.is_action_pressed('left_click') and can_shoot:  shoot()


func _integrate_forces(state):
    
    if state.get_contact_count() >= 1:  loopThroughColContacts(state)
    
    setPrevFrameDir(state)
    
    applyMoveAcc()
    
    applyMoveMaxSpeed()
    
    applySpinAcc()
    
    applySpinDamp()
    
    applySpinMaxSpeed()


####################################################################################################
""" _ready FUNCS """


func setCameraParams():
    var map_limits = tile_map.get_used_rect()
    var map_cellsize = tile_map.cell_size
    $GamePlayCamera.limit_left = map_limits.position.x * map_cellsize.x
    $GamePlayCamera.limit_right = map_limits.end.x * map_cellsize.x
    $GamePlayCamera.limit_top = map_limits.position.y * map_cellsize.y
    $GamePlayCamera.limit_bottom = map_limits.end.y * map_cellsize.y


####################################################################################################
""" _integrate_forces FUNCS """


func applyMoveAcc():
    if Input.is_action_pressed('up') and Input.is_action_pressed('down'):
        applied_force = Vector2()
        linear_damp = 5
    elif Input.is_action_pressed('up'):
        applied_force = Vector2(0, -MOVE_ACC).rotated(rotation)
        linear_damp = 0
    elif Input.is_action_pressed('down'):
        applied_force = -Vector2(0, -MOVE_ACC).rotated(rotation)
        linear_damp = 0
    else:
        applied_force = Vector2()
        linear_damp = 0


func applyMoveMaxSpeed():
    if linear_velocity.length() > MOVE_MAX_SPEED:  applied_force = linear_velocity * -MOVE_MAX_SPEED_RESISTANCE


func applySpinAcc():
    if Input.is_action_pressed('right'):  applied_torque = +SPIN_ACC
    elif Input.is_action_pressed('left'):  applied_torque = -SPIN_ACC
    else:  applied_torque = 0


func applySpinDamp():
    # make sure ship only spins when button is pressed
    if Input.is_action_just_pressed('right') or Input.is_action_just_pressed('left'):  angular_damp = 0
    elif Input.is_action_just_released('right') or Input.is_action_just_released('left'):  angular_damp = 200


func applySpinMaxSpeed():
    if abs(angular_velocity) > SPIN_MAX_SPEED:  applied_torque = angular_velocity * -SPIN_MAX_SPEED_RESISTANCE


func setPrevFrameDir(state):
    prev_frame_dir = rad2deg(state.linear_velocity.angle())
    prev_frame_dir = prev_frame_dir if prev_frame_dir > 0 else 360 + prev_frame_dir


func loopThroughColContacts(state):
    for col_i in state.get_contact_count():
        if state.get_contact_collider_object(col_i).name == 'TileMap' and can_take_terrain_col_dmg:
            can_take_terrain_col_dmg = false
            $CanTakeTerrainColDmgTimer.start()
            var col_dp = gameplay.getTerrainColDataPack(self, state, col_i)
            var terrain_col_dmg = getTerrainColDmgFromDataPack(col_dp)
            health -= terrain_col_dmg * 20
            gameplay.setTerrainColParticlesFromDataPack(col_dp)
            hud.updateHealthValues(health)


func getTerrainColDmgFromDataPack(data_pack) -> float:
    var col_dmg = MAX_TERRAIN_COL_DMG * data_pack['speed_damp'] * data_pack['col_angle_damp'] * (1.0 - PHYSICAL_ARMOR)
    return col_dmg


####################################################################################################


func shoot():
    can_shoot = false
    $CanShootTimer.start()
    var dir = Vector2(1, 0).rotated($Turret.global_rotation - deg2rad(90))
    var b = bullet_01.instance()
    projectiles.add_child(b)
    b.start($Turret/BulletSpawn.global_position, dir)


####################################################################################################
""" signal FUNCS """


func _on_CanShootTimer_timeout():
    can_shoot = true


func _on_DropPickUp_body_entered(body):
    if body.get_parent().name == 'Drops':
        body.shipSensed()


func _on_CanTakeTerrainColDmgTimer_timeout():
    can_take_terrain_col_dmg = true
