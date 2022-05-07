
extends RigidBody2D

onready var tile_map = get_node('/root/Main/TileMap')

onready var projectiles = get_node('/root/Main/Projectiles')
onready var bullet_01 = preload('res://scenes/Bullet01.tscn')

var MOVE_ACC = 250
var MOVE_MAX_SPEED = 180
var MOVE_MAX_SPEED_RESISTANCE = 5

var SPIN_ACC = 2000
var SPIN_MAX_SPEED = 7
var SPIN_MAX_SPEED_RESISTANCE = 10

var TURRET_COOL_DOWN = 0.8

var can_shoot = true


####################################################################################################


func _ready():
    
    setCameraParams()
    
    $CanShootTimer.wait_time = TURRET_COOL_DOWN


func _physics_process(_delta):
    
    $Turret.look_at(get_global_mouse_position())
    $Turret.rotate(deg2rad(90))
    
    if Input.is_action_pressed('left_click') and can_shoot:  shoot()


func _integrate_forces(_state):
    
    applyMoveAcc()
    
    applyMoveMaxSpeed()
    
    applySpinAcc()
    
    applySpinDamp()
    
    applySpinMaxSpeed()


####################################################################################################
""" _ready FUNCS """


func setCameraParams():
    if tile_map:
        var map_limits = tile_map.get_used_rect()
        var map_cellsize = tile_map.cell_size
        $GamePlayCamera.limit_left = map_limits.position.x * map_cellsize.x
        $GamePlayCamera.limit_right = map_limits.end.x * map_cellsize.x
        $GamePlayCamera.limit_top = map_limits.position.y * map_cellsize.y
        $GamePlayCamera.limit_bottom = map_limits.end.y * map_cellsize.y
    else:
        $GamePlayCamera.current = false


####################################################################################################
""" _integrate_forces FUNCS """


func applyMoveAcc():
    if Input.is_action_pressed('up'):  applied_force = Vector2(0, -MOVE_ACC).rotated(rotation)
    elif Input.is_action_pressed('down'):  applied_force = -Vector2(0, -MOVE_ACC).rotated(rotation)
    else:  applied_force = Vector2()


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


####################################################################################################


func shoot():
    can_shoot = false
    $CanShootTimer.start()
    var dir = Vector2(1, 0).rotated($Turret.global_rotation - deg2rad(90))
    var b = bullet_01.instance()
    projectiles.add_child(b)
    b.start($Turret/BulletSpawn.global_position, dir)


####################################################################################################


func _on_CanShootTimer_timeout():
    can_shoot = true
