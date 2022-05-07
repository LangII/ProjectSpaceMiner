
extends Node

onready var main = get_node('/root/Main')

onready var tile_map = preload("res://scenes/TileMap.tscn").instance()
onready var destruct_tile_map = preload("res://scenes/DestructTileMap.tscn").instance()
onready var mini_tile_map = preload("res://scenes/MiniTileMap.tscn").instance()

var TILE_MAP_WIDTH = 200
var TILE_MAP_HEIGHT = 200

var NOISE_OCTAVES = 3  # 1 = 3 = 9 (int) (edge distortion)
var NOISE_PERIOD = 64  # 0.1 = 64 = 256 (float) (noise size)
var NOISE_PERSISTENCE = 0.5  # 0 = 0.5 = 1 (float)
var NOISE_LACUNARITY = 2  # 0.1 = 2 = 4 (float)

var TILE_L00_AIR = 0
var TILE_L00_PERMANENT = 1
var TILE_L00_PERMANENT_AIR = 2
var TILE_L01 = 3
var TILE_L01_COL = 4
var TILE_L01_2EDGE_COL = 5
var TILE_L01_3EDGE_COL = 6
var TILE_L02 = 7
var TILE_L02_COL = 8
var TILE_L02_2EDGE_COL = 9
var TILE_L02_3EDGE_COL = 10
var TILE_L02_2EDGE_NONCOL = 11
var TILE_L02_3EDGE_NONCOL = 12
var TILE_L03 = 13
var TILE_L03_COL = 14
var TILE_L03_2EDGE_COL = 15
var TILE_L03_3EDGE_COL = 16
var TILE_L03_2EDGE_NONCOL = 17
var TILE_L03_3EDGE_NONCOL = 18

var DESTRUCT_TILE_AIR = 0
var DESTRUCT_TILE_25 = 1
var DESTRUCT_TILE_50 = 2
var DESTRUCT_TILE_75 = 3
var DESTRUCT_TILE_2EDGE_25 = 4
var DESTRUCT_TILE_2EDGE_50 = 5
var DESTRUCT_TILE_2EDGE_75 = 6
var DESTRUCT_TILE_3EDGE_25 = 7
var DESTRUCT_TILE_3EDGE_50 = 8
var DESTRUCT_TILE_3EDGE_75 = 9

var TILE_01_HEALTH = 80
var TILE_02_HEALTH = 500
var TILE_03_HEALTH = 2000

var TILE_2EDGE_DIR_CODE = {
    'NE': {'flip_x': false, 'flip_y': false, 'transpose': false},
    'ES': {'flip_x': false, 'flip_y': true, 'transpose': false},
    'SW': {'flip_x': true,  'flip_y': true,  'transpose': false},
    'NW': {'flip_x': true,  'flip_y': false, 'transpose': false}
}
var TILE_3EDGE_DIR_CODE = {
    'NES': {'flip_x': true,  'flip_y': false, 'transpose': true},
    'ESW': {'flip_x': false, 'flip_y': true,  'transpose': false},
    'NSW': {'flip_x': false, 'flip_y': false, 'transpose': true},
    'NEW': {'flip_x': false, 'flip_y': false, 'transpose': false},
}

var LEVEL_NOISE = [
    {'TILE_LEVEL': 0, 'TILE_CODE': TILE_L00_AIR, 'LOW': 0.00, 'HIGH': 0.20},
    {'TILE_LEVEL': 1, 'TILE_CODE': TILE_L01, 'LOW': 0.20, 'HIGH': 0.30},
    {'TILE_LEVEL': 2, 'TILE_CODE': TILE_L02, 'LOW': 0.30, 'HIGH': 0.40},
    {'TILE_LEVEL': 3, 'TILE_CODE': TILE_L03, 'LOW': 0.40, 'HIGH': 1.10}
]

var TILE_COL_MAP = {
    1: {
        '1': {'TILE_REF': TILE_L01_COL, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': TILE_L01_COL, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': TILE_L01_2EDGE_COL, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': TILE_L01_3EDGE_COL, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': TILE_L01_COL, 'DIR_CODE_REF': null}
    },
    2: {
        '1': {'TILE_REF': TILE_L02_COL, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': TILE_L02_COL, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': TILE_L02_2EDGE_COL, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': TILE_L02_3EDGE_COL, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': TILE_L02_COL, 'DIR_CODE_REF': null}
    },
    3: {
        '1': {'TILE_REF': TILE_L03_COL, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': TILE_L03_COL, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': TILE_L03_2EDGE_COL, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': TILE_L03_3EDGE_COL, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': TILE_L03_COL, 'DIR_CODE_REF': null}
    },
}

var TILE_EDGE_MAP = {
    2: {
        '1': {'TILE_REF': TILE_L02, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': TILE_L02, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': TILE_L02_2EDGE_NONCOL, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': TILE_L02_3EDGE_NONCOL, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': TILE_L02, 'DIR_CODE_REF': null}
    },
    3: {
        '1': {'TILE_REF': TILE_L03, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': TILE_L03, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': TILE_L03_2EDGE_NONCOL, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': TILE_L03_3EDGE_NONCOL, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': TILE_L03, 'DIR_CODE_REF': null}
    },
}

var DESTRUCT_TILE_MAP = {
    1: {
        '1': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_25, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': DESTRUCT_TILE_3EDGE_25, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null}
    },
    2: {
        '1': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_50, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': DESTRUCT_TILE_3EDGE_50, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null}
    },
    3: {
        '1': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null},
        '2pa': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null},
        '2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_75, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
        '3': {'TILE_REF': DESTRUCT_TILE_3EDGE_75, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
        '4': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null}
    },
}

var noise = OpenSimplexNoise.new()

onready var tile_data = {}


####################################################################################################


func _ready():
    
    main.add_child(tile_map)
    main.add_child(destruct_tile_map)
#    main.add_child(mini_tile_map)
    
    randomize()
    
    setNoiseParams()
    print("noise.seed = ", noise.seed)
    
    initTileDataContainer()
    
    setTileDataPhaseOne()
    
    setTileDataPhaseTwo()
    
    setTileDataPhaseThree()
    
    if mini_tile_map in main.get_children():
        tile_map.visible = false


####################################################################################################
""" _ready FUNCS """


func setNoiseParams():
    noise.seed = randi()
    noise.octaves = NOISE_OCTAVES
    noise.period = NOISE_PERIOD
    noise.persistence = NOISE_PERSISTENCE
    noise.lacunarity = NOISE_LACUNARITY


func initTileDataContainer():
    for y in TILE_MAP_HEIGHT:
        for x in TILE_MAP_WIDTH:
            tile_data['%s,%s' % [y, x]] = {'y': y, 'x': x, 'pos': [y, x]}


func setTileDataPhaseOne():
    
    for k in tile_data.keys():
        var y = tile_data[k]['y']
        var x = tile_data[k]['x']
        
        setTileDataNoise(k, y, x)
        
        setTileDataTileLevelAndTileCode(k)
        
        setTileDataHealth(k)
        
        setTileDataDestructs(k)


func setTileDataPhaseTwo():
    
    for k in tile_data.keys():
        var y = tile_data[k]['y']
        var x = tile_data[k]['x']
    
        setTileDataNeighborPos(k, y, x)
        
        setTileDataNeighborTileLevelAndCode(k)
        
        setTileDataCol(k)
        
        setTileDataAirCount(k)
        
        setTileDataAirDirCode(k)
        
        setTileDataEdge(k)
        
        setTileDataEdgeCount(k)
        
        setTileDataEdgeDirCode(k)
        
        setTileMapCells(k, y, x)
        
        updateTileMapColTile(k, y, x)
        
        updateTileMapEdgeTile(k, y, x)


func setTileDataPhaseThree():
    
    updateBorderWall()


####################################################################################################
""" _ready / setTileDataPhaseOne FUNCS """


func setTileDataNoise(k, y, x):
    tile_data[k]['noise'] = noise.get_noise_2d(x, y)


func setTileDataTileLevelAndTileCode(k):
    for ln in LEVEL_NOISE:
        if (
            (tile_data[k]['noise'] >= +ln['LOW'] and tile_data[k]['noise'] < +ln['HIGH']) or
            (tile_data[k]['noise'] >= -ln['HIGH'] and tile_data[k]['noise'] < -ln['LOW'])
        ):
            tile_data[k]['tile_level'] = ln['TILE_LEVEL']
            tile_data[k]['tile_code'] = ln['TILE_CODE']


func setTileDataHealth(k):
    var tile_health
    match tile_data[k]['tile_level']:
        0:  tile_health = null
        1:  tile_health = TILE_01_HEALTH
        2:  tile_health = TILE_02_HEALTH
        3:  tile_health = TILE_03_HEALTH
    tile_data[k]['max_health'] = tile_health
    tile_data[k]['health'] = tile_health


func setTileDataDestructs(k):
    tile_data[k]['destruct_tile_level'] = 0
    tile_data[k]['destruct_tile_code'] = null


####################################################################################################
""" _ready / setTileDataPhaseTwo FUNCS """


func setTileDataNeighborPos(k, y, x):
    tile_data[k]['neighbors_pos'] = {
        'N': [y - 1, x],
        'E': [y, x + 1],
        'S': [y + 1, x],
        'W': [y, x - 1]
    }
    if y == 0:  tile_data[k]['neighbors_pos']['N'] = null
    if x == 0:  tile_data[k]['neighbors_pos']['W'] = null
    if y == TILE_MAP_HEIGHT - 1:  tile_data[k]['neighbors_pos']['S'] = null
    if x == TILE_MAP_WIDTH - 1:  tile_data[k]['neighbors_pos']['E'] = null


func setTileDataNeighborTileLevelAndCode(k):
    tile_data[k]['neighbors_tile_level'] = {}
    tile_data[k]['neighbors_tile_code'] = {}
    for dir in ['N', 'E', 'S', 'W']:
        var neighbor_pos = tile_data[k]['neighbors_pos'][dir]
        if neighbor_pos:
            tile_data[k]['neighbors_tile_level'][dir] = tile_data['%s,%s' % neighbor_pos]['tile_level']
            tile_data[k]['neighbors_tile_code'][dir] = tile_data['%s,%s' % neighbor_pos]['tile_code']
        else:
            tile_data[k]['neighbors_tile_level'][dir] = null
            tile_data[k]['neighbors_tile_code'][dir] = null


func setTileDataCol(k):
    tile_data[k]['is_col'] = false
    if tile_data[k]['tile_code'] == 0:  return
    for dir in ['N', 'E', 'S', 'W']:
        if tile_data[k]['neighbors_tile_code'][dir] == 0:
            tile_data[k]['is_col'] = true
            break


func setTileDataAirCount(k):
    tile_data[k]['air_count'] = null
    if tile_data[k]['tile_code'] == 0:  return
    var air_count = 0
    for value in tile_data[k]['neighbors_tile_level'].values():
        if value == 0:  air_count += 1
    tile_data[k]['air_count'] = air_count


func setTileDataAirDirCode(k):
    tile_data[k]['air_dir_code'] = ''
    if tile_data[k]['tile_code'] == 0:  return
    var air_dir_code = ''
    for dir in ['N', 'E', 'S', 'W']:
        if tile_data[k]['neighbors_tile_level'][dir] == 0:  air_dir_code += dir
    tile_data[k]['air_dir_code'] = air_dir_code


func setTileDataEdge(k):
    tile_data[k]['is_edge'] = false
    if tile_data[k]['tile_code'] == 0:  return
    if tile_data[k]['tile_level'] != 1:
        var own_level_count = tile_data[k]['neighbors_tile_level'].values().count(tile_data[k]['tile_level'])
        var lower_level_count = tile_data[k]['neighbors_tile_level'].values().count(tile_data[k]['tile_level'] - 1)
        if lower_level_count and (own_level_count + lower_level_count == 4):
            tile_data[k]['is_edge'] = true


func setTileDataEdgeCount(k):
    tile_data[k]['edge_count'] = null
    if tile_data[k]['tile_code'] == 0:  return
    var edge_count = 0
    for value in tile_data[k]['neighbors_tile_level'].values():
        if value == tile_data[k]['tile_level'] - 1:  edge_count += 1
    tile_data[k]['edge_count'] = edge_count


func setTileDataEdgeDirCode(k):
    tile_data[k]['edge_dir_code'] = ''
    if tile_data[k]['tile_code'] == 0:  return
    var edge_dir_code = ''
    for dir in ['N', 'E', 'S', 'W']:
        if tile_data[k]['neighbors_tile_level'][dir] == tile_data[k]['tile_level'] - 1:
            edge_dir_code += dir
    tile_data[k]['edge_dir_code'] = edge_dir_code


func setTileMapCells(k, y, x):
    tile_map.set_cell(x, y, tile_data[k]['tile_code'])
    if mini_tile_map:
        mini_tile_map.set_cell(x, y, tile_data[k]['tile_level'])


func getModTypeCount(type, k):
    # type = 'air' or 'edge'
    var count_type = '%s_count' % [type]
    var dir_code_type = '%s_dir_code' % [type]
    var mod_air_count = ''
    if tile_data[k][count_type] == 2:
        if tile_data[k][dir_code_type] in ['NS', "EW"]:  mod_air_count = '2pa'
        else:  mod_air_count = '2pe'
    else:  mod_air_count = str(tile_data[k][count_type])
    return mod_air_count



func updateTileMapColTile(k, y, x):
    if not tile_data[k]['is_col']:  return
    var mod_air_count = getModTypeCount('air', k)
    var tile_ref = TILE_COL_MAP[tile_data[k]['tile_level']][mod_air_count]['TILE_REF']
    var dir_code_ref = TILE_COL_MAP[tile_data[k]['tile_level']][mod_air_count]['DIR_CODE_REF']
    if dir_code_ref:
        var dir_code = dir_code_ref[tile_data[k]['air_dir_code']]
        tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
    else:
        tile_map.set_cell(x, y, tile_ref)


func updateTileMapEdgeTile(k, y, x):
    if not tile_data[k]['is_edge']:  return
    var mod_edge_count = getModTypeCount('edge', k)
    var tile_ref = TILE_EDGE_MAP[tile_data[k]['tile_level']][mod_edge_count]['TILE_REF']
    var dir_code_ref = TILE_EDGE_MAP[tile_data[k]['tile_level']][mod_edge_count]['DIR_CODE_REF']
    if dir_code_ref:
        var dir_code = dir_code_ref[tile_data[k]['edge_dir_code']]
        tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
    else:
        tile_map.set_cell(x, y, tile_ref)


####################################################################################################
""" _ready / setTileDataPhaseThree FUNCS """


func updateBorderWall():
    var updating_coords = []
    # get coords for left and right walls
    for y in TILE_MAP_HEIGHT:
        for x in [0, TILE_MAP_WIDTH - 1]:
            updating_coords += [[y, x]]
    # get coords for top and bottom walls
    for x in TILE_MAP_WIDTH:
        for y in [0, TILE_MAP_HEIGHT - 1]:
            updating_coords += [[y, x]]
    # update tile data of wall coords
    for coord in updating_coords:
        var y = coord[0]
        var x = coord[1]
        var k = '%s,%s' % [y, x]
        tile_data[k]['tile_level'] = 0
        tile_data[k]['tile_code'] = TILE_L00_PERMANENT
        tile_map.set_cell(x, y, tile_data[k]['tile_code'])


####################################################################################################
""" externally called FUNCS """


func tileTakesDmg(tile_pos, dmg):
    var k = '%s,%s' % [tile_pos.y, tile_pos.x]
    if tile_data[k]['tile_level'] == 0:  return
    tile_data[k]['health'] -= dmg
    if tile_data[k]['health'] < 0:  tile_data[k]['health'] = 0
    updateTileDataDestructTileLevel(k)
    updateDestructTileMapCell(k, tile_pos.y, tile_pos.x)
    if tile_data[k]['health'] == 0:  tileDestroyed(k)


func updateTileDataDestructTileLevel(k):
    var dmg_taken = tile_data[k]['max_health'] - tile_data[k]['health']
    var dmg_perc = float(dmg_taken) / float(tile_data[k]['max_health'])
    if dmg_perc >= 0.25 and dmg_perc < 0.50:  tile_data[k]['destruct_tile_level'] = 1
    elif dmg_perc >= 0.50 and dmg_perc < 0.75:  tile_data[k]['destruct_tile_level'] = 2
    elif dmg_perc >= 0.75:  tile_data[k]['destruct_tile_level'] = 3


func updateDestructTileMapCell(k, y, x):
    if not tile_data[k]['destruct_tile_level']:  return
    var mod_air_count = getModTypeCount('air', k)
    var tile_ref = DESTRUCT_TILE_MAP[tile_data[k]['destruct_tile_level']][mod_air_count]['TILE_REF']
    var dir_code_ref = DESTRUCT_TILE_MAP[tile_data[k]['destruct_tile_level']][mod_air_count]['DIR_CODE_REF']
    if dir_code_ref:
        var dir_code = dir_code_ref[tile_data[k]['air_dir_code']]
        destruct_tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
    else:
        destruct_tile_map.set_cell(x, y, tile_ref)


func tileDestroyed(k):
    areaTileUpdateFromCol(k)


func areaTileUpdateFromCol(k):
    if tile_data[k]['tile_level'] == 0:  return
    var pos = tile_data[k]['pos']   
    tile_data[k]['tile_level'] = 0
    tile_data[k]['tile_code'] = 0
    setTileMapCells(k, pos[0], pos[1])
    tile_data[k]['destruct_tile_level'] = 0
    destruct_tile_map.set_cell(pos[1], pos[0], 0)
    for n_pos in tile_data[k]['neighbors_pos'].values():
        if not n_pos:  continue
        var n_k = '%s,%s' % n_pos
        if tile_data[n_k]['tile_level'] == 0:  continue
        var n_y = n_pos[0]
        var n_x = n_pos[1]
        setTileDataTileLevelAndTileCode(n_k)
        setTileDataNeighborTileLevelAndCode(n_k)
        setTileDataCol(n_k)
        setTileDataAirCount(n_k)
        setTileDataAirDirCode(n_k)
        setTileDataEdge(n_k)
        setTileDataEdgeCount(n_k)
        setTileDataEdgeDirCode(n_k)
        setTileMapCells(n_k, n_y, n_x)
        updateTileMapColTile(n_k, n_y, n_x)
        updateTileMapEdgeTile(n_k, n_y, n_x)
        updateTileDataDestructTileLevel(n_k)
        updateDestructTileMapCell(n_k, n_y, n_x)




