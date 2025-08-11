
extends 'res://scripts/tiles/a-MothershipTileDataTileMapLogic.gd'

onready var main = get_node('/root/Main')
onready var util = get_node('/root/Main/Utilities')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

onready var tile_map = preload("res://scenes/tiles/TileMap.tscn").instance()
onready var destruct_tile_map = preload("res://scenes/tiles/DestructTileMap.tscn").instance()
onready var mineral_tile_map = preload("res://scenes/tiles/MineralTileMap.tscn").instance()
onready var mini_tile_map = preload("res://scenes/tiles/MiniTileMap.tscn").instance()


####################################################################################################
""" constants """


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

var MINI_TILE_L00 = 0
var MINI_TILE_L01 = 1
var MINI_TILE_L02 = 2
var MINI_TILE_L03 = 3

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
		'0': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null},
		'1': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null},
		'2pa': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null},
		'2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_25, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
		'3': {'TILE_REF': DESTRUCT_TILE_3EDGE_25, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
		'4': {'TILE_REF': DESTRUCT_TILE_25, 'DIR_CODE_REF': null}
	},
	2: {
		'0': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null},
		'1': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null},
		'2pa': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null},
		'2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_50, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
		'3': {'TILE_REF': DESTRUCT_TILE_3EDGE_50, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
		'4': {'TILE_REF': DESTRUCT_TILE_50, 'DIR_CODE_REF': null}
	},
	3: {
		'0': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null},
		'1': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null},
		'2pa': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null},
		'2pe': {'TILE_REF': DESTRUCT_TILE_2EDGE_75, 'DIR_CODE_REF': TILE_2EDGE_DIR_CODE},
		'3': {'TILE_REF': DESTRUCT_TILE_3EDGE_75, 'DIR_CODE_REF': TILE_3EDGE_DIR_CODE},
		'4': {'TILE_REF': DESTRUCT_TILE_75, 'DIR_CODE_REF': null}
	},
}

var noise = OpenSimplexNoise.new()


####################################################################################################
""" adjustable constants """


onready var TILE_MAP_WIDTH = util.coalesce([null, ctrl.basetilemaplogic_tile_map_width])
onready var TILE_MAP_HEIGHT = util.coalesce([null, ctrl.basetilemaplogic_tile_map_height])

onready var NOISE_OCTAVES = util.coalesce([null, ctrl.basetilemaplogic_noise_octaves])  # 1 = 3 = 9 (int) (edge distortion)
onready var NOISE_PERIOD = util.coalesce([null, ctrl.basetilemaplogic_noise_period])  # 0.1 = 64 = 256 (float) (noise size)
onready var NOISE_PERSISTENCE = util.coalesce([null, ctrl.basetilemaplogic_noise_persistence])  # 0 = 0.5 = 1 (float)
onready var NOISE_LACUNARITY = util.coalesce([null, ctrl.basetilemaplogic_noise_lacunarity])  # 0.1 = 2 = 4 (float)

onready var BOARDER_WALL_TILE_LEVEL = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_tile_level])
onready var BOARDER_WALL_NOISE_MAX_HEIGHT = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_noise_max_height])
onready var BOARDER_WALL_NOISE_OCTAVES = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_noise_octaves])  # 1 = 3 = 9 (int) (edge distortion)
onready var BOARDER_WALL_NOISE_PERIOD = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_noise_period])  # 0.1 = 64 = 256 (float) (noise size)
onready var BOARDER_WALL_NOISE_PERSISTENCE = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_noise_persistence])  # 0 = 0.5 = 1 (float)
onready var BOARDER_WALL_NOISE_LACUNARITY = util.coalesce([null, ctrl.basetilemaplogic_boarder_wall_noise_lacunarity])  # 0.1 = 2 = 4 (float)

onready var SAFE_ZONE_START_HEIGHT = util.coalesce([null, ctrl.basetilemaplogic_safe_zone_start_height])

onready var TILE_01_HEALTH = util.coalesce([null, ctrl.basetilemaplogic_tile_01_health])
onready var TILE_02_HEALTH = util.coalesce([null, ctrl.basetilemaplogic_tile_02_health])
onready var TILE_03_HEALTH = util.coalesce([null, ctrl.basetilemaplogic_tile_03_health])

onready var NOISE_SETTINGS = [
	{
		'TILE_LEVEL': 0,
		'TILE_CODE': TILE_L00_AIR,
		'MINI_TILE_CODE': MINI_TILE_L00,
		'LOW': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_0_low]),
		'HIGH': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_0_high])
	},
	{
		'TILE_LEVEL': 1,
		'TILE_CODE': TILE_L01,
		'MINI_TILE_CODE': MINI_TILE_L01,
		'LOW': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_1_low]),
		'HIGH': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_1_high])
	},
	{
		'TILE_LEVEL': 2,
		'TILE_CODE': TILE_L02,
		'MINI_TILE_CODE': MINI_TILE_L02,
		'LOW': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_2_low]),
		'HIGH': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_2_high])
	},
	{
		'TILE_LEVEL': 3,
		'TILE_CODE': TILE_L03,
		'MINI_TILE_CODE': MINI_TILE_L03,
		'LOW': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_3_low]),
		'HIGH': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_3_high])
	}
]


####################################################################################################
""" _ready FUNCS """


func tileDataLoop(func_ref:FuncRef, _k:bool=false, _kyx:bool=false) -> void:
	if _k and _kyx:
		util.throwError("in 'tileDataLoop' 'k' and 'kyx' can not both be 'true'")
	for k in data.tiles.keys():
		var y = data.tiles[k]['y']
		var x = data.tiles[k]['x']
		if _k:  func_ref.call_func(k)
		elif _kyx:  func_ref.call_func(k, y, x)


func setNoiseParams():
	noise.octaves = NOISE_OCTAVES
	noise.period = NOISE_PERIOD
	noise.persistence = NOISE_PERSISTENCE
	noise.lacunarity = NOISE_LACUNARITY


func initTileDataContainer():
	for y in TILE_MAP_HEIGHT:
		for x in TILE_MAP_WIDTH:
			data.tiles['%s,%s' % [y, x]] = {
				'y': y,
				'x': x,
				'pos': [y, x],
				'global_pos_center': tile_map.map_to_world(Vector2(x, y)) + (tile_map.cell_size / 2),
				'noise': null,
				'tile_level': 0,
				'tile_code': 0,
				'mini_tile_code': 0,
				'is_mineral': false,
				'is_terraform': false,
				'is_fixture': false,
				'fixture_id': null,
				'mineral_type': null,
				'mineral_drop_value': 0
			}


func setTileDataNoise(k, y, x):
	data.tiles[k]['noise'] = abs(noise.get_noise_2d(x, y))


func setBoarderWallFrom1dNoise():
	noise.octaves = BOARDER_WALL_NOISE_OCTAVES
	noise.period = BOARDER_WALL_NOISE_PERIOD
	noise.persistence = BOARDER_WALL_NOISE_PERSISTENCE
	noise.lacunarity = BOARDER_WALL_NOISE_LACUNARITY
	
	var air_noise_set = getSingleNoiseSetting(0)
	var preset_noise_set = getSingleNoiseSetting(BOARDER_WALL_TILE_LEVEL)
	var preset_noise = float((preset_noise_set['HIGH'] - preset_noise_set['LOW']) / 2) + preset_noise_set['LOW']
	
	# left wall
	for y in TILE_MAP_HEIGHT:
		var wall_width = int(round(util.normalize(noise.get_noise_1d(y), -1, +1, 0, BOARDER_WALL_NOISE_MAX_HEIGHT)))
		for x in wall_width:
			subFuncSetWallNoise(y, x, air_noise_set, preset_noise)
	
	# right wall
	for y in TILE_MAP_HEIGHT:
		var wall_width = int(round(util.normalize(noise.get_noise_1d(y), -1, +1, 0, BOARDER_WALL_NOISE_MAX_HEIGHT)))
		for x in wall_width:
			x = (TILE_MAP_WIDTH - 1) - x
			subFuncSetWallNoise(y, x, air_noise_set, preset_noise)
	
	# bottom wall
	for x in TILE_MAP_WIDTH:
		var wall_height = int(round(util.normalize(noise.get_noise_1d(x), -1, +1, 0, BOARDER_WALL_NOISE_MAX_HEIGHT)))
		for y in wall_height:
			y = (TILE_MAP_HEIGHT - 1) - y
			subFuncSetWallNoise(y, x, air_noise_set, preset_noise)
	
	setNoiseParams()


func subFuncSetWallNoise(y, x, air_noise_set, preset_noise):
	var k = '%s,%s' % [y, x]
	if data.tiles[k]['noise'] < air_noise_set['LOW'] or data.tiles[k]['noise'] >= air_noise_set['HIGH']:  return
	data.tiles[k]['noise'] = preset_noise


func updateNoiseWithVertLinearFade(min_row, max_row, min_weight, max_weight):
	for y in range(min_row, max_row):
		var modifier = util.normalize(y, min_row, max_row, min_weight, max_weight)
		for x in TILE_MAP_WIDTH:
			data.tiles['%s,%s' % [y, x]]['noise'] *= modifier


func setTileDataTileLevelAndTileCode(k):
	for ln in NOISE_SETTINGS:
		if data.tiles[k]['noise'] >= ln['LOW'] and data.tiles[k]['noise'] < ln['HIGH']:
			data.tiles[k]['tile_level'] = ln['TILE_LEVEL']
			data.tiles[k]['tile_code'] = ln['TILE_CODE']
			data.tiles[k]['mini_tile_code'] = ln['MINI_TILE_CODE']


func setTileMapCells(k, y, x):
	
	# this logic will have to be revisited.  for now, the logic for all Fixtures is that if 1 of their
	# Tiles is destroyed, the entire Fixture is destroyed (Mothership).  later i want to have "destructible"
	# Fixtures, where if 1 Tile is destroyed, the Fixture can still remain in game.  so this will be
	# relevant due to tile updates from neighbor destruction
	if data.tiles[k]['is_fixture']:  return
	
	tile_map.set_cell(x, y, data.tiles[k]['tile_code'])
	mini_tile_map.set_cell(x, y, data.tiles[k]['mini_tile_code'])


func setTileDataHealth(k):
	var tile_health
	match data.tiles[k]['is_fixture']:
		false:
			match data.tiles[k]['tile_level']:
				0:  tile_health = null
				1:  tile_health = TILE_01_HEALTH
				2:  tile_health = TILE_02_HEALTH
				3:  tile_health = TILE_03_HEALTH
		true:
			var fixture_tile = null
			
			# as other fixtures will be added, fixture_tile_data will have to be expanded to
			# include OTHER_FIXTURE_TILE_DATA
			var fixture_tile_data = MOTHERSHIP_TILE_DATA
			
			for tile_data in fixture_tile_data:
				if tile_data['fixture_id'] == data.tiles[k]['fixture_id']:
					fixture_tile = tile_data
					break
			tile_health = fixture_tile['health']
	data.tiles[k]['max_health'] = tile_health
	data.tiles[k]['health'] = tile_health


func setTileDataDestructs(k):
	data.tiles[k]['destruct_tile_level'] = 0
	data.tiles[k]['destruct_tile_code'] = null


func setTileDataNeighborPos(k, y, x):
	
	# 1st set pos values
	data.tiles[k]['neighbors_pos'] = {
		'N': [y - 1, x],
		'E': [y, x + 1],
		'S': [y + 1, x],
		'W': [y, x - 1]
	}
	
	# 2nd, if neighbor_pos is "off map", set value to null
	if y == 0:  data.tiles[k]['neighbors_pos']['N'] = null
	if x == 0:  data.tiles[k]['neighbors_pos']['W'] = null
	if y == TILE_MAP_HEIGHT - 1:  data.tiles[k]['neighbors_pos']['S'] = null
	if x == TILE_MAP_WIDTH - 1:  data.tiles[k]['neighbors_pos']['E'] = null


func setTileDataNeighborTileLevelTileCodeIsFixture(k):
	
	data.tiles[k]['neighbors_tile_level'] = {}
	data.tiles[k]['neighbors_tile_code'] = {}
	data.tiles[k]['neighbors_is_fixture'] = {}
	for dir in ['N', 'E', 'S', 'W']:
		
		# set neighbor tile values using neighbor_pos as key of data.tiles
		var neighbor_pos = data.tiles[k]['neighbors_pos'][dir]
		if neighbor_pos:
			data.tiles[k]['neighbors_tile_level'][dir] = data.tiles['%s,%s' % neighbor_pos]['tile_level']
			data.tiles[k]['neighbors_tile_code'][dir] = data.tiles['%s,%s' % neighbor_pos]['tile_code']
			data.tiles[k]['neighbors_is_fixture'][dir] = data.tiles['%s,%s' % neighbor_pos]['is_fixture']
		
		# set values to null if neighbor tile is "off map"
		else:
			data.tiles[k]['neighbors_tile_level'][dir] = null
			data.tiles[k]['neighbors_tile_code'][dir] = null
			data.tiles[k]['neighbors_is_fixture'][dir] = null


func setTileDataIsCol(k):
	"""
	tiles that CAN BE col tiles:
		terrain tiles
		fixture tiles
	tiles that, as neighbors, DETERMINE IF A TILE IS a col tile:
		air tiles
		fixture tiles
	so FIXTURE tiles can be COL tiles and are considered in determining if a tile is a col tile or not.
	this makes for odd logic, but is necessary in ensuring that terrain "that support" fixture tiles,
	remain as col tiles even "under the surface"
	"""
	
	# set is_col to false
	data.tiles[k]['is_col'] = false
	
	# if tile is air (tile_code = 0), this tile stays with is_col = false
	if data.tiles[k]['tile_code'] == 0:  return
	
	# check to see if any neighbors are air (tile_code = 0) or are a fixture tile, if a neighbor is
	# air or a fixture, then this tile is_col
	for dir in ['N', 'E', 'S', 'W']:
		if (
			data.tiles[k]['neighbors_tile_code'][dir] == 0
			or data.tiles[k]['neighbors_is_fixture'][dir] == true
		):
			data.tiles[k]['is_col'] = true
			break


func setTileDataAirCount(k):
	data.tiles[k]['air_count'] = null
	if data.tiles[k]['tile_code'] == 0:  return
	var air_count = 0
	for value in data.tiles[k]['neighbors_tile_level'].values():
		if value == 0:  air_count += 1
	data.tiles[k]['air_count'] = air_count


func setTileDataAirDirCode(k):
	data.tiles[k]['air_dir_code'] = ''
	if data.tiles[k]['tile_code'] == 0:  return
	var air_dir_code = ''
	for dir in ['N', 'E', 'S', 'W']:
		if data.tiles[k]['neighbors_tile_level'][dir] == 0:  air_dir_code += dir
	data.tiles[k]['air_dir_code'] = air_dir_code


func setTileDataEdge(k):
	data.tiles[k]['is_edge'] = false
	if data.tiles[k]['tile_code'] == 0:  return
	if data.tiles[k]['tile_level'] != 1:
		var own_level_count = data.tiles[k]['neighbors_tile_level'].values().count(data.tiles[k]['tile_level'])
		var lower_level_count = data.tiles[k]['neighbors_tile_level'].values().count(data.tiles[k]['tile_level'] - 1)
		if lower_level_count and (own_level_count + lower_level_count == 4):
			data.tiles[k]['is_edge'] = true


func setTileDataEdgeCount(k):
	data.tiles[k]['edge_count'] = null
	if data.tiles[k]['tile_code'] == 0:  return
	var edge_count = 0
	for value in data.tiles[k]['neighbors_tile_level'].values():
		if value == data.tiles[k]['tile_level'] - 1:  edge_count += 1
	data.tiles[k]['edge_count'] = edge_count


func setTileDataEdgeDirCode(k):
	data.tiles[k]['edge_dir_code'] = ''
	if data.tiles[k]['tile_code'] == 0:  return
	var edge_dir_code = ''
	for dir in ['N', 'E', 'S', 'W']:
		if data.tiles[k]['neighbors_tile_level'][dir] == data.tiles[k]['tile_level'] - 1:
			edge_dir_code += dir
	data.tiles[k]['edge_dir_code'] = edge_dir_code


func getModTypeCount(type, k):
	# type = 'air' or 'edge'
	
	var count_type = '%s_count' % [type]
	var dir_code_type = '%s_dir_code' % [type]
	var mod_air_count = ''
	
	if data.tiles[k][count_type] == 2:
		if data.tiles[k][dir_code_type] in ['NS', "EW"]:
			mod_air_count = '2pa'
		else:
			mod_air_count = '2pe'
	else:
		mod_air_count = str(data.tiles[k][count_type])
	
	return mod_air_count



func updateTileMapColTile(k, y, x):
	
	if not data.tiles[k]['is_col']:  return
	
	# this logic will have to be revisited.  for now, the logic for all Fixtures is that if 1 of their
	# Tiles is destroyed, the entire Fixture is destroyed (Mothership).  later i want to have "destructible"
	# Fixtures, where if 1 Tile is destroyed, the Fixture can still remain in game
	if data.tiles[k]['is_fixture']:  return
	
	var mod_air_count = getModTypeCount('air', k)
	if data.tiles[k]['is_mineral']:
		mod_air_count = '4'
	var tile_ref = TILE_COL_MAP[data.tiles[k]['tile_level']][mod_air_count]['TILE_REF']
	var dir_code_ref = TILE_COL_MAP[data.tiles[k]['tile_level']][mod_air_count]['DIR_CODE_REF']
	if dir_code_ref:
		var dir_code = dir_code_ref[data.tiles[k]['air_dir_code']]
		tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
	else:
		tile_map.set_cell(x, y, tile_ref)


func updateTileMapEdgeTile(k, y, x):
	if not data.tiles[k]['is_edge']:  return
	var mod_edge_count = getModTypeCount('edge', k)
	if data.tiles[k]['is_mineral']:  mod_edge_count = '4'
	var tile_ref = TILE_EDGE_MAP[data.tiles[k]['tile_level']][mod_edge_count]['TILE_REF']
	var dir_code_ref = TILE_EDGE_MAP[data.tiles[k]['tile_level']][mod_edge_count]['DIR_CODE_REF']
	if dir_code_ref:
		var dir_code = dir_code_ref[data.tiles[k]['edge_dir_code']]
		tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
	else:
		tile_map.set_cell(x, y, tile_ref)


func updateBoarderWall():
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
		data.tiles[k]['tile_level'] = 0
		data.tiles[k]['tile_code'] = TILE_L00_PERMANENT
		tile_map.set_cell(x, y, data.tiles[k]['tile_code'])


func updateAirBoarderWall():
	# update top wall
	for x in TILE_MAP_WIDTH:
		var k = '%s,%s' % [0, x]
		data.tiles[k]['tile_code'] = TILE_L00_PERMANENT_AIR
		tile_map.set_cell(x, 0, data.tiles[k]['tile_code'])
	# update left wall
	for y in TILE_MAP_HEIGHT:
		if data.tiles['%s,%s' % [y, 1]]['tile_level'] != 0:  continue
		var k = '%s,%s' % [y, 0]
		data.tiles[k]['tile_code'] = TILE_L00_PERMANENT_AIR
		tile_map.set_cell(0, y, data.tiles[k]['tile_code'])
	# update right wall
	for y in TILE_MAP_HEIGHT:
		if data.tiles['%s,%s' % [y, TILE_MAP_WIDTH - 2]]['tile_level'] != 0:  continue
		var k = '%s,%s' % [y, TILE_MAP_WIDTH - 1]
		data.tiles[k]['tile_code'] = TILE_L00_PERMANENT_AIR
		tile_map.set_cell(TILE_MAP_WIDTH - 1, y, data.tiles[k]['tile_code'])


####################################################################################################
""" helper FUNCS """


func getSingleNoiseSetting(tile_level:int) -> Dictionary:
	var single_noise_setting = null
	for ns in NOISE_SETTINGS:
		if ns['TILE_LEVEL'] == tile_level:
			single_noise_setting = ns
			break
	if not single_noise_setting:
		util.throwError("'tile_level' '%s' in 'getSingleNoiseSettings()' not found in 'NOISE_SETTINGS'" % [tile_level])
	return single_noise_setting


####################################################################################################
""" externally called FUNCS """


func tileTakesDmg(tile_pos, dmg):
	var k = '%s,%s' % [tile_pos.y, tile_pos.x]
	if data.tiles[k]['tile_level'] == 0:  return
	data.tiles[k]['health'] -= dmg
	if data.tiles[k]['health'] < 0:  data.tiles[k]['health'] = 0
	updateTileDataDestructTileLevel(k)
	updateDestructTileMapCell(k, tile_pos.y, tile_pos.x)
	if data.tiles[k]['health'] == 0:  tileDestroyed(k)


func updateTileDataDestructTileLevel(k):
	var dmg_taken = data.tiles[k]['max_health'] - data.tiles[k]['health']
	var dmg_perc = float(dmg_taken) / float(data.tiles[k]['max_health'])
	if dmg_perc >= 0.25 and dmg_perc < 0.50:  data.tiles[k]['destruct_tile_level'] = 1
	elif dmg_perc >= 0.50 and dmg_perc < 0.75:  data.tiles[k]['destruct_tile_level'] = 2
	elif dmg_perc >= 0.75:  data.tiles[k]['destruct_tile_level'] = 3


func updateDestructTileMapCell(k, y, x):
	if not data.tiles[k]['destruct_tile_level']:
		return
	var mod_air_count = getModTypeCount('air', k)
	if data.tiles[k]['is_mineral']:
		mod_air_count = '4'
	var tile_ref = DESTRUCT_TILE_MAP[data.tiles[k]['destruct_tile_level']][mod_air_count]['TILE_REF']
	var dir_code_ref = DESTRUCT_TILE_MAP[data.tiles[k]['destruct_tile_level']][mod_air_count]['DIR_CODE_REF']
	if dir_code_ref:
		var dir_code = dir_code_ref[data.tiles[k]['air_dir_code']]
		destruct_tile_map.set_cell(x, y, tile_ref, dir_code['flip_x'], dir_code['flip_y'], dir_code['transpose'])
	else:
		destruct_tile_map.set_cell(x, y, tile_ref)


func tileDestroyed(k):
	areaTileUpdateFromCol(k)
	if data.tiles[k]['is_mineral']:
		mineral_tile_map.set_cell(data.tiles[k]['x'], data.tiles[k]['y'], -1)
		gameplay.initDrop(
			data.tiles[k]['mineral_type'], data.tiles[k]['mineral_drop_value'],
			data.tiles[k]['global_pos_center']
		)
	gameplay.checkForEnemy03ToFloating(k)


func areaTileUpdateFromCol(k):
	if data.tiles[k]['tile_level'] == 0:  return
	var pos = data.tiles[k]['pos']   
	data.tiles[k]['tile_level'] = 0
	data.tiles[k]['tile_code'] = 0
	setTileMapCells(k, pos[0], pos[1])
	data.tiles[k]['destruct_tile_level'] = 0
	destruct_tile_map.set_cell(pos[1], pos[0], 0)
	for n_pos in data.tiles[k]['neighbors_pos'].values():
		if not n_pos:  continue
		var n_k = '%s,%s' % n_pos
		if data.tiles[n_k]['tile_level'] == 0:  continue
		var n_y = n_pos[0]
		var n_x = n_pos[1]
		setTileDataTileLevelAndTileCode(n_k)
		setTileDataNeighborTileLevelTileCodeIsFixture(n_k)
		setTileDataIsCol(n_k)
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
