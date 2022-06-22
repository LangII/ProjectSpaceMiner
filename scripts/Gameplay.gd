
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

#onready var SEED = util.rng.randi()
#onready var SEED = hash('1234')
onready var SEED = 4057731354

var hud = null


####################################################################################################


func _ready():
    
    print("SEED = ", SEED)
    util.rng.seed = SEED
    
    var tile_map_logic = load('res://scenes/tiles/TileMapLogic.tscn').instance()
    tile_map_logic.noise.seed = SEED
    main.add_child(tile_map_logic)
    if tile_map_logic.mini_map_test:  return
    
    var ship = load('res://scenes/Ship.tscn').instance()
    add_child(ship)
    
    for i in 10:
        var enemy = load('res://scenes/Enemy01.tscn').instance()
        enemy.global_position = Vector2(240, 1050)
        enemy.HOME_POS = Vector2(240, 1050)
        enemy.HOME_RADIUS = 100.0
        add_child(enemy)
    
    hud = load('res://scenes/Hud.tscn').instance()
    add_child(hud)


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














