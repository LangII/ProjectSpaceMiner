
extends Node

onready var main = get_node('/root/Main')
onready var util = get_node('/root/Main/Utilities')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

onready var tile_map_logic = gameplay.get_node('TileMapLogic')
onready var mini_tile_map = gameplay.get_node('MiniTileMap')

onready var _enemies_ = gameplay.get_node('Enemies')

onready var enemy_01 = preload('res://scenes/Enemy01.tscn')

onready var ENEMY_GEN_MAP = {
    'ENEMY_01': {
        'SWARM_ATTEMPTS': {'MIN': 10, 'MAX': 20},
        'COUNT_PER_SWARM': {'MIN': 5, 'MAX': 10},
        'HOME_RADIUS_TILE_COUNT': {'MIN': 4, 'MAX': 10}
    }
}


####################################################################################################


func genEnemy01s():
    
    var gen_map = ENEMY_GEN_MAP['ENEMY_01']
    var swarm_attempts = util.getRandomInt(gen_map['SWARM_ATTEMPTS']['MIN'], gen_map['SWARM_ATTEMPTS']['MAX'])
    var count_per_swarm = util.getRandomInt(gen_map['COUNT_PER_SWARM']['MIN'], gen_map['COUNT_PER_SWARM']['MAX'])
    var home_radius_tile_count = util.getRandomInt(gen_map['HOME_RADIUS_TILE_COUNT']['MIN'], gen_map['HOME_RADIUS_TILE_COUNT']['MAX'])
    
    print("swarm_attempts = ", swarm_attempts)
    print("count_per_swarm = ", count_per_swarm)
    print("home_radius_tile_count = ", home_radius_tile_count)
    
    var swarm_attempted_coords = []
    var good_swarm_coords = []
    for i in swarm_attempts:
        var x = util.getRandomInt(0, ctrl.tile_map_width - 1)
        var y = util.getRandomInt(0 + tile_map_logic.AIR_FADE_START_HEIGHT, ctrl.tile_map_height - 1)
        
        swarm_attempted_coords += ['%s,%s' % [y, x]]
        
        var near_coords = getNearCoords(x, y, 5)
        
        if isNearSolidTiles(near_coords):  continue
        
        var too_close_to_other_swarm = false
        for good_swarm_coord in good_swarm_coords:
            if good_swarm_coord in near_coords:
                too_close_to_other_swarm = true
                break
        if too_close_to_other_swarm:  continue
        
        good_swarm_coords += ['%s,%s' % [y, x]]
        
        if gameplay.mini_map_test:  setMiniTileMapEnemyPos(x, y)
        
        setEnemy01Swarm(x, y, count_per_swarm, home_radius_tile_count)
    
    print("swarm_attempted_coords = ", swarm_attempted_coords)
    print("good_swarm_coords = ", good_swarm_coords)


####################################################################################################


func getNearCoords(_x:int, _y:int, _how_near:int) -> Array:
    var near_coords = []
    for y in range(max(_y - _how_near, 0), min(_y + _how_near, ctrl.tile_map_height - 1)):
        for x in range(max(_x - _how_near, 0), min(_x + _how_near, ctrl.tile_map_width - 1)):
            near_coords += ['%s,%s' % [y, x]]
    return near_coords


func isNearSolidTiles(_near_coords) -> bool:
    var is_solid_bools = []
    for coord in _near_coords:
        if data.tiles[coord]['tile_level'] != 0:  return true
    return false


func setMiniTileMapEnemyPos(_x:int, _y:int, _buffer:int=1) -> void:
    for y in range(max(_y - _buffer, 0), min(_y + _buffer, ctrl.tile_map_height - 1)):
        for x in range(max(_x - _buffer, 0), min(_x + _buffer, ctrl.tile_map_width - 1)):
            mini_tile_map.set_cell(x, y, 5)


func setEnemy01Swarm(_home_x_tile:int, _home_y_tile:int, _enemy_count:int, _home_radius_tile:int) -> void:
    var enemy_pos = Vector2(_home_x_tile * 20, _home_y_tile * 20)
    for i in _enemy_count:
        var enemy = load('res://scenes/Enemy01.tscn').instance()
        enemy.global_position = enemy_pos
        enemy.HOME_POS = enemy_pos
        enemy.HOME_RADIUS_TILE_COUNT = _home_radius_tile
        _enemies_.add_child(enemy)



















