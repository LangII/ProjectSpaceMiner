
extends Node

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var util = get_node('/root/Main/Utilities')

onready var drop = preload('res://scenes/Drop.tscn')
onready var mineral_01_texture = preload('res://sprites/tiles/mineral_01.png')
onready var mineral_02_texture = preload('res://sprites/tiles/mineral_02.png')
onready var mineral_03_texture = preload('res://sprites/tiles/mineral_03.png')

onready var DROP_TEXTURE_MAP = {
    'mineral_01': mineral_01_texture,
    'mineral_02': mineral_02_texture,
    'mineral_03': mineral_03_texture
}

var TILE_MAP_LOGIC_SCN_REF = 'res://scenes/tiles/TileMapLogic.tscn'
var SHIP_SCN_REF = 'res://scenes/Ship.tscn'
var HUD_SCN_REF = 'res://scenes/Hud.tscn'

#onready var SEED = util.rng.randi()
#onready var SEED = hash('bender rules')
onready var SEED = 4057731354

var tile_map_logic = null
var tile_map = null
var ship = null
var camera = null
var hud = null


var cam_noise = OpenSimplexNoise.new()
var cam_shake_noise_x = 0
var cam_shake_trauma = 0.0
var CAM_SHAKE_SPEED = 5  # 1 - 10
var CAM_SHAKE_DECAY = 0.4
var CAM_SHAKE_OFFSET_MOD = 200
var CAM_SHAKE_TRAUMA_MOD = 2.2
var CAM_SHAKE_MAX_OFFSET = 10


####################################################################################################


func _ready():
    
    print("SEED = ", SEED)
    util.rng.seed = SEED
    
    addTileMap()
    if tile_map_logic.mini_map_test:  return
    
    addShip()
    
    addCamera()
    
    addHud()
    
    var enemies = get_node('Enemies')
    var enemy_pos = Vector2(650, 50)
    for i in 10:
        var enemy = load('res://scenes/Enemy01.tscn').instance()
        enemy.global_position = enemy_pos
        enemy.HOME_POS = enemy_pos
        enemy.HOME_RADIUS = 100.0
        enemies.add_child(enemy)


func _process(delta):
    if cam_shake_trauma:
        cam_shake_trauma = max(cam_shake_trauma - (CAM_SHAKE_DECAY * delta), 0)
        shakeCam()


####################################################################################################
""" _ready FUNCS """


func addTileMap():
    tile_map_logic = load(TILE_MAP_LOGIC_SCN_REF).instance()
    tile_map_logic.noise.seed = SEED
    add_child(tile_map_logic)
    tile_map = get_node('TileMap')


func addShip():
    ship = load(SHIP_SCN_REF).instance()
    add_child(ship)


func addCamera():
    # set noise attributes
    cam_noise.seed = SEED
    cam_noise.period = CAM_SHAKE_SPEED
    # init camera
    camera = Camera2D.new()
    camera.current = true
    # set camera limits
    var map_limits = tile_map.get_used_rect()
    var map_cellsize = tile_map.cell_size
    camera.limit_left = map_limits.position.x * map_cellsize.x
    camera.limit_right = map_limits.end.x * map_cellsize.x
    camera.limit_top = map_limits.position.y * map_cellsize.y
    camera.limit_bottom = map_limits.end.y * map_cellsize.y
    # add camera
    ship.add_child(camera)


func addHud():
    hud = load(HUD_SCN_REF).instance()
    add_child(hud)


####################################################################################################
""" _process FUNCS """


func shakeCam():
    var amount = pow(cam_shake_trauma, CAM_SHAKE_TRAUMA_MOD)
    cam_shake_noise_x += 1
    camera.offset.x = clamp(
        CAM_SHAKE_OFFSET_MOD * amount * cam_noise.get_noise_1d(cam_shake_noise_x),
        -CAM_SHAKE_MAX_OFFSET, CAM_SHAKE_OFFSET_MOD
    )
    camera.offset.y = clamp(
        CAM_SHAKE_OFFSET_MOD * amount * cam_noise.get_noise_1d(cam_shake_noise_x + 1_000),
        -CAM_SHAKE_MAX_OFFSET, CAM_SHAKE_OFFSET_MOD
    )


####################################################################################################


func initDrop(drop_type, drop_value, pos):
    var new_drop = drop.instance()
    new_drop.get_node('Sprite').texture = DROP_TEXTURE_MAP[drop_type]
    new_drop.DROP_TYPE = drop_type
    new_drop.DROP_VALUE = drop_value
    new_drop.global_position = pos
    $Drops.add_child(new_drop)


func dropCollected(drop_type, drop_value):
    var drop_is_new = null
    if not drop_type in data.drops_collected.keys():
        data.drops_collected[drop_type] = {'count': 1, 'value': drop_value}
        drop_is_new = true
    else:
        data.drops_collected[drop_type]['count'] += 1
        data.drops_collected[drop_type]['value'] += drop_value
        drop_is_new = false
    hud.dropCollected(drop_is_new, drop_type)


func getTerrainColDataPack(ship_obj, col_state, col_i) -> Dictionary:
    var data_pack = {}
    data_pack['col_pos'] = col_state.get_contact_local_position(col_i)
    data_pack['speed_damp'] = clamp(
        util.normalize(
            ship_obj.linear_velocity.length(), 0,
            ship_obj.MOVE_MAX_SPEED * ship_obj.COL_DMG_SPEED_MODIFIER, 0, 1
        ),
        0, 1
    )
    data_pack['col_angle'] = 90 - abs(rad2deg(
        col_state.get_contact_local_normal(col_i).angle_to(ship_obj.linear_velocity)
    ))
    data_pack['col_angle_damp'] = util.normalize(data_pack['col_angle'], 0, 90, 0, 1)
    data_pack['prev_frame_dir'] = ship_obj.prev_frame_dir
    return data_pack


func setTerrainColParticlesFromDataPack(data_pack):
    $ShipToTerrainColParticles2D.global_position = data_pack['col_pos']
    $ShipToTerrainColParticles2D.global_rotation_degrees = data_pack['prev_frame_dir'] + 90
    $ShipToTerrainColParticles2D.process_material.spread = data_pack['col_angle']
    $ShipToTerrainColParticles2D.lifetime = 1 * data_pack['speed_damp']
    $ShipToTerrainColParticles2D.restart()


func setEnemyColParticles(_pos):
    $ShipToEnemyColParticles2D.global_position = _pos
    $ShipToEnemyColParticles2D.restart()


func setShipShootBulletParticles(_pos, _rot):
    $ShipShootBulletParticles2D.global_position = _pos
    $ShipShootBulletParticles2D.rotation = _rot
    $ShipShootBulletParticles2D.restart()













