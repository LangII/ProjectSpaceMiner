
extends Node

onready var main = get_node('/root/Main')
onready var util = get_node('/root/Main/Utilities')

onready var tile_map = preload("res://scenes/TileMap.tscn").instance()
onready var destruct_tile_map = preload("res://scenes/DestructTileMap.tscn").instance()
onready var mini_tile_map = preload("res://scenes/MiniTileMap.tscn").instance()

var TILE_MAP_WIDTH = 600
var TILE_MAP_HEIGHT = 200

var BOARDER_NOISE_MAX_HEIGHT = 10
var BOARDER_NOISE_OCTAVES = 2  # 1 = 3 = 9 (int) (edge distortion)
var BOARDER_NOISE_PERIOD = 40  # 0.1 = 64 = 256 (float) (noise size)
var BOARDER_NOISE_PERSISTENCE = 0.9  # 0 = 0.5 = 1 (float)
var BOARDER_NOISE_LACUNARITY = 3.5  # 0.1 = 2 = 4 (float)

var BOARDER_AIR_NOISE_MAX_HEIGHT = 50
var BOARDER_AIR_NOISE_OCTAVES = 4  # 1 = 3 = 9 (int) (edge distortion)
var BOARDER_AIR_NOISE_PERIOD = 30  # 0.1 = 64 = 256 (float) (noise size)
var BOARDER_AIR_NOISE_PERSISTENCE = 0.5  # 0 = 0.5 = 1 (float)
var BOARDER_AIR_NOISE_LACUNARITY = 0.5  # 0.1 = 2 = 4 (float)

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
    
    main.add_child(mini_tile_map)
    
    randomize()
    
#    noise.seed = randi()
    noise.seed = 1234
    setNoiseParams()
    print("noise.seed = ", noise.seed)
    
    initTileDataContainer()
    
    
    
    setTileDataPhaseOne()
    
    if mini_tile_map in main.get_children():
        for k in tile_data.keys():
            var y = tile_data[k]['y']
            var x = tile_data[k]['x']
            setTileMapCells(k, y, x)
        return
    
    setTileDataPhaseTwo()
    
    setTileDataPhaseThree()
    
    if mini_tile_map in main.get_children():
        tile_map.visible = false


####################################################################################################
""" _ready FUNCS """


func setNoiseParams():
    noise.octaves = NOISE_OCTAVES
    noise.period = NOISE_PERIOD
    noise.persistence = NOISE_PERSISTENCE
    noise.lacunarity = NOISE_LACUNARITY


func initTileDataContainer():
    for y in TILE_MAP_HEIGHT:
        for x in TILE_MAP_WIDTH:
            tile_data['%s,%s' % [y, x]] = {
                'y': y,
                'x': x,
                'pos': [y, x],
                'tile_level': 0,
                'tile_code': 0,
                'noise': null
            }


func setBoarderWallFrom1dNoise():
    noise.octaves = BOARDER_NOISE_OCTAVES
    noise.period = BOARDER_NOISE_PERIOD
    noise.persistence = BOARDER_NOISE_PERSISTENCE
    noise.lacunarity = BOARDER_NOISE_LACUNARITY
    
    var selected_noise = null
    for level_noise in LEVEL_NOISE:
        if level_noise['TILE_LEVEL'] == 1:  selected_noise = level_noise
    var wall_noise = float((selected_noise['HIGH'] - selected_noise['LOW']) / 2) + selected_noise['LOW']
#    print("wall_noise = ", wall_noise)
    
    # left wall
    for y in TILE_MAP_HEIGHT:
        var boarder_noise = noise.get_noise_1d(y)
        var tile_level = int(round(util.normalize(boarder_noise, -1, +1, 0, BOARDER_NOISE_MAX_HEIGHT)))
        for x in tile_level:
            var k = '%s,%s' % [y, x]
            if tile_data[k]['tile_level'] != 0:  continue
            tile_data[k]['noise'] = wall_noise
            tile_data[k]['tile_level'] = 1
            tile_data[k]['tile_code'] = TILE_L01
#            tile_map.set_cell(x, y, tile_data[k]['tile_code'])
#            if mini_tile_map in main.get_children():
#                mini_tile_map.set_cell(x, y, tile_data[k]['tile_level'])
    
    # right wall
    for y in TILE_MAP_HEIGHT:
        var boarder_noise = noise.get_noise_1d(y)
        var tile_level = int(round(util.normalize(boarder_noise, -1, +1, 0, BOARDER_NOISE_MAX_HEIGHT)))
        for x in tile_level:
            x = (TILE_MAP_WIDTH - 1) - x
            var k = '%s,%s' % [y, x]
            if tile_data[k]['tile_level'] != 0:  continue
            tile_data[k]['noise'] = wall_noise
            tile_data[k]['tile_level'] = 1
            tile_data[k]['tile_code'] = TILE_L01
#            tile_map.set_cell(x, y, tile_data[k]['tile_code'])
#            if mini_tile_map in main.get_children():
#                mini_tile_map.set_cell(x, y, tile_data[k]['tile_level'])
    
    # bottom wall
    for x in TILE_MAP_WIDTH:
        var boarder_noise = noise.get_noise_1d(x)
        var tile_level = int(round(util.normalize(boarder_noise, -1, +1, 0, BOARDER_NOISE_MAX_HEIGHT)))
        for y in tile_level:
            y = (TILE_MAP_HEIGHT - 1) - y
            var k = '%s,%s' % [y, x]
            if tile_data[k]['tile_level'] != 0:  continue
            tile_data[k]['noise'] = wall_noise
            tile_data[k]['tile_level'] = 1
            tile_data[k]['tile_code'] = TILE_L01
#            tile_map.set_cell(x, y, tile_data[k]['tile_code'])
#            if mini_tile_map in main.get_children():
#                mini_tile_map.set_cell(x, y, tile_data[k]['tile_level'])
    
    setNoiseParams()


func setTileDataPhaseOne():
    
    for k in tile_data.keys():
        var y = tile_data[k]['y']
        var x = tile_data[k]['x']
        
        setTileDataNoise(k, y, x, true)
    
    
    
    for k in tile_data.keys():
        setTileDataTileLevelAndTileCode(k)

    setBoarderWallFrom1dNoise()
    
    updateNoiseWithVerticalFade()
    
    for k in tile_data.keys():
        setTileDataTileLevelAndTileCode(k)
    
#    setBoarderAirNoise()
    
#    setTerrainCapFromAirNoise()
    
#    var counter = 1
#    for k in tile_data.keys():
#        if counter > 100:  break
#        print("tile_data[k] = ", tile_data[k])
#        counter += 1
    
    
#    for k in tile_data.keys():
#        var y = tile_data[k]['y']
#        var x = tile_data[k]['x']
#        setTileMapCells(k, y, x)
##        print("\nk = ", k)
##        print("y = ", y)
##        print("x = ", x)
#        updateTileMapColTile(k, y, x)
#        updateTileMapEdgeTile(k, y, x)


func setTileDataPhaseTwo():
    
    for k in tile_data.keys():
        var y = tile_data[k]['y']
        var x = tile_data[k]['x']
        
        setTileDataHealth(k)
#
        setTileDataDestructs(k)
    
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


func setTileDataNoise(k, y, x, replace=false):
    if not replace and tile_data[k]['noise']:  return
    tile_data[k]['noise'] = noise.get_noise_2d(x, y)


func updateNoiseWithVerticalFade():
    for y in TILE_MAP_HEIGHT / 2:
        var modifier = util.normalize(y, 0, TILE_MAP_HEIGHT / 2, 0, 1)
        for x in TILE_MAP_WIDTH:
            var k = '%s,%s' % [y, x]
            tile_data[k]['noise'] *= modifier


func setTileDataTileLevelAndTileCode(k):
    for ln in LEVEL_NOISE:
        if (
            (tile_data[k]['noise'] >= +ln['LOW'] and tile_data[k]['noise'] < +ln['HIGH']) or
            (tile_data[k]['noise'] >= -ln['HIGH'] and tile_data[k]['noise'] < -ln['LOW'])
        ):
            
#            # If air, ignore prev created boarder tiles.
#            if ln['TILE_LEVEL'] == 0 and tile_data[k]['tile_level']:  return
            
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
    
#    print("mod_air_count = ", mod_air_count)
#    print("tile_data[k] = ", tile_data[k])
    
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


func setBoarderAirNoise():
    noise.octaves = BOARDER_AIR_NOISE_OCTAVES
    noise.period = BOARDER_AIR_NOISE_PERIOD
    noise.persistence = BOARDER_AIR_NOISE_PERSISTENCE
    noise.lacunarity = BOARDER_AIR_NOISE_LACUNARITY
    for x in TILE_MAP_WIDTH:
        var boarder_noise = noise.get_noise_1d(x)
        var air_level = int(round(util.normalize(boarder_noise, -1, +1, 0, BOARDER_AIR_NOISE_MAX_HEIGHT)))
        for y in air_level:
#            y = (TILE_MAP_HEIGHT - 1) - y
            var k = '%s,%s' % [y, x]
#            print("k = ", k)
            tile_data[k]['tile_level'] = 0
            tile_data[k]['tile_code'] = TILE_L00_AIR
            tile_map.set_cell(x, y, tile_data[k]['tile_code'])
            if mini_tile_map in main.get_children():
                mini_tile_map.set_cell(x, y, tile_data[k]['tile_level'])
        
        setTerrainCapAfterAirNoise(air_level, x)
        
    setNoiseParams()


func setTerrainCapAfterAirNoise(y, x):
    var cap_width = 4
#    var top_tile_level = tile_data['%s,%s' % [y, x]]['tile_level']
    var top_tile_level = getTopTileLevel(y, x)
    if top_tile_level <= 1:  return
    if top_tile_level == 3:
#        print("MADE IT HERE")
        for n in cap_width:
            n += cap_width
            var new_y = y + n
            var new_k = '%s,%s' % [new_y, x]
            tile_data[new_k]['tile_level'] = 2
            tile_data[new_k]['tile_code'] = TILE_L02
            tile_map.set_cell(x, new_y, tile_data[new_k]['tile_code'])
            if mini_tile_map in main.get_children():
                mini_tile_map.set_cell(x, new_y, tile_data[new_k]['tile_level'])
    for n in cap_width:
#        n += 1
        var new_y = y + n
        var new_k = '%s,%s' % [new_y, x]
        tile_data[new_k]['tile_level'] = 1
        tile_data[new_k]['tile_code'] = TILE_L01
        tile_map.set_cell(x, new_y, tile_data[new_k]['tile_code'])
        if mini_tile_map in main.get_children():
            mini_tile_map.set_cell(x, new_y, tile_data[new_k]['tile_level'])


func getTopTileLevel(y, x):
    var cap_width = 4
    var top_tile_levels = []
    for n in cap_width:
        n += 1
        var k = '%s,%s' % [y + n, x]
        top_tile_levels += [tile_data[k]['tile_level']]
    return top_tile_levels.max()


func setTerrainCapFromAirNoise():
    
#    return
    
    var cap_width = 2
    var neighbor_width = 2
    var levels = [1, 2, 3]
    
#    levels.remove(len(levels) - 1)
#    print("levels = ", levels)
    
    var loop_levels = levels.duplicate(true)
    loop_levels.remove(len(loop_levels) - 1)
    loop_levels.invert()
    
#    print("levels = ", levels)
#    print("loop_levels = ", loop_levels)
    
    for l in loop_levels:
#    for l in levels:
        print("l = ", l)
        var cap_dict = getCapDict()
        for cap in cap_dict.keys():
            
            var has_neighbor = false
            if cap_dict[cap]['level'] == l:
                for nw in neighbor_width:
                    nw += 1
                    var new_plus_cap = str(int(cap) + nw)
                    if int(new_plus_cap) <= TILE_MAP_WIDTH - 1 and cap_dict[new_plus_cap]['level'] == l + 1:
                        print("\n", cap_dict[cap])
                        print(cap_dict[new_plus_cap])
                        has_neighbor = true
                        break
                    var new_minus_cap = str(int(cap) - nw)
                    if int(new_minus_cap) >= 0 and cap_dict[new_minus_cap]['level'] == l + 1:
                        print("\n", cap_dict[cap])
                        print(cap_dict[new_minus_cap])
                        has_neighbor = true
                        break
#            if has_neighbor:  print("HAS NEIGHBOR (%s)" % [cap])
            
#            var has_neighbor = false
#            for n in neighbor_width:
#                n += 1
#                var n_y = cap_dict[cap]['pos'][0]
#                var n_x = cap_dict[cap]['pos'][1]
#                var neighbors = []
#                for cap_2 in cap_dict.keys():
#                    if cap_dict[cap_2]['pos'][1] in [n_x + n, n_x - 1]:
#                        neighbors += [cap_2]
#                for neigh in neighbors:
#                    if cap_dict[neigh]['level'] == l + 1:
#                        has_neighbor = true
#                        break
##                if cap_dict['%s,%s' % [n_y, n_x + n]]['level'] == l + 1:
##                    has_neighbor = true
##                    break
##                if cap_dict['%s,%s' % [n_y, n_x - n]]['level'] == l + 1:
##                    has_neighbor = true
##                    break
            
            if cap_dict[cap]['level'] in [l, l + 1]:
#            if cap_dict[cap]['level'] in [l, l + 1]:
                
                var y = cap_dict[cap]['pos'][0]
                var x = cap_dict[cap]['pos'][1]
                
                tile_data['%s,%s' % [y - 1, x]]['tile_level'] = l
                match l:
                    1:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L01
                    2:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L02
    #                3:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L03
                
                tile_data['%s,%s' % [y - 2, x]]['tile_level'] = l
                match l:
                    1:  tile_data['%s,%s' % [y - 2, x]]['tile_code'] = TILE_L01
                    2:  tile_data['%s,%s' % [y - 2, x]]['tile_code'] = TILE_L02
    #                3:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L03
            
#            if has_neighbor:
#
#                var y = cap_dict[cap]['pos'][0]
#                var x = cap_dict[cap]['pos'][1]
#
                tile_data['%s,%s' % [y - 3, x]]['tile_level'] = l
                match l:
                    1:  tile_data['%s,%s' % [y - 3, x]]['tile_code'] = TILE_L01
                    2:  tile_data['%s,%s' % [y - 3, x]]['tile_code'] = TILE_L02
    #                3:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L03

                tile_data['%s,%s' % [y - 4, x]]['tile_level'] = l
                match l:
                    1:  tile_data['%s,%s' % [y - 4, x]]['tile_code'] = TILE_L01
                    2:  tile_data['%s,%s' % [y - 4, x]]['tile_code'] = TILE_L02
    #                3:  tile_data['%s,%s' % [y - 1, x]]['tile_code'] = TILE_L03
                
                
#                var tile_array = []
#                for n in cap_dict[cap]['level']:
#                    n += 1
#                    for i in cap_width:  tile_array += [n]
#                tile_array.invert()
#
#                print("tile_array = ", tile_array)
#
#                var cur_y = cap_dict[cap]['pos'][0] - 1
#                for tile in tile_array:
#
#                    var k = '%s,%s' % [cur_y, cap_dict[cap]['pos'][1]]
#                    tile_data[k]['tile_level'] = tile
#                    match tile:
#                        1:  tile_data[k]['tile_code'] = TILE_L01
#                        2:  tile_data[k]['tile_code'] = TILE_L02
#                    cur_y -= 1
                
    
#    var cap_dict = getCapDict()
##    print("cap_dict = ", cap_dict)
#
#    for cap in cap_dict.keys():
#        if cap_dict[cap]['level'] == 1:  continue
##        print("\ncap_dict[cap] = ", cap_dict[cap])
#        var tile_array = []
#        for n in cap_dict[cap]['level']:
##            print("n = ", n)
#            n += 1
#            for i in cap_width:  tile_array += [n]
#        tile_array.invert()
##        print("tile_array = ", tile_array)
#        var y = cap_dict[cap]['pos'][0]
#        var x = cap_dict[cap]['pos'][1]
#        var cur_y = y - 1
#        for tile in tile_array:
#            var cur_k = '%s,%s' % [cur_y, x]
#            tile_data[cur_k]['tile_level'] = tile
#            match tile:
#                1:  tile_data[cur_k]['tile_code'] = TILE_L01
#                2:  tile_data[cur_k]['tile_code'] = TILE_L02
#                3:  tile_data[cur_k]['tile_code'] = TILE_L03
#            cur_y -= 1
    
#    for col in cap_dict.keys():
#        if cap_dict[col]['level'] == 1:  continue
#        var x = cap_dict[col]['pos'][1]
#        var y = cap_dict[col]['pos'][0]
#        var tile_array = []
#        for n in cap_dict[col]['level']:
#            n += 1
#            for i in cap_width:  tile_array += [n]
#        tile_array.invert()
##        print("tile_array = ", tile_array)
#        var new_y = y
#        for tile in tile_array:
#            new_y -= 1
#            tile_data['%s,%s' % [new_y, x]]['tile_level'] = tile


func getCapDict():
    var cap_dict = {}
    for x in TILE_MAP_WIDTH:
        for y in TILE_MAP_HEIGHT:
            var k = '%s,%s' % [y, x]
            if tile_data[k]['tile_level'] != 0:
                cap_dict[str(x)] = {'k': k, 'pos': [y, x], 'level': tile_data[k]['tile_level']}
                break
    return cap_dict


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




