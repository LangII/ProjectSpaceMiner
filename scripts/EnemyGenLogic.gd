
extends Node

onready var main = get_node('/root/Main')
onready var util = get_node('/root/Main/Utilities')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')

onready var tile_map_logic = gameplay.get_node('TileMapLogic')
onready var tile_map = gameplay.get_node('TileMap')
onready var mini_tile_map = gameplay.get_node('MiniTileMap')

onready var _enemies_ = gameplay.get_node('Enemies')

onready var enemy_01 = preload('res://scenes/Enemy01.tscn')
onready var enemy_02 = preload('res://scenes/Enemy02.tscn')
onready var enemy_03 = preload('res://scenes/Enemy03.tscn')

onready var ENEMY_GEN_MAP = {
	'ENEMY_01': {
		'SPAWN_ATTEMPTS_PER_BOTTOM_PERC': {
			1.00: {'MIN': 5, 'MAX': 10},
			0.50: {'MIN': 5, 'MAX': 10},
			0.25: {'MIN': 5, 'MAX': 10}
		},
		'NEAR_COORDS_DIST': {'MIN': 2, 'MAX': 8},  # by tile
		'HOME_RADIUS': {'MIN': 4, 'MAX': 10},  # by tile
		'COUNT_PER_SWARM': {'MIN': 2, 'MAX': 4},
	},
	'ENEMY_02': {
		'SPAWN_ATTEMPTS_PER_BOTTOM_PERC': {
			1.00: {'MIN': 2, 'MAX': 5},
			0.50: {'MIN': 2, 'MAX': 5},
			0.25: {'MIN': 2, 'MAX': 5},
		},
		'NEAR_COORDS_DIST': {'MIN': 4, 'MAX': 8},  # by tile
		'SEGMENT_COUNT': {'MIN': 4, 'MAX': 20},
	},
	'ENEMY_03': {
		'SPAWN_ATTEMPTS_PER_BOTTOM_PERC': {
			1.00: {'MIN': 1, 'MAX': 3},
			0.50: {'MIN': 2, 'MAX': 6},
			0.25: {'MIN': 2, 'MAX': 10},
		},
		'NEAR_COORDS_DIST': {'MIN': 2, 'MAX': 4},  # by tile
	}
}


####################################################################################################


func genEnemy01s() -> void:
	
	""" for manual placement testing """
#	for x in [
#		{'x': 27, 'y': 116, 'count': 2, 'home_radius':4},
#	]:  genEnemy01Swarm(x['x'], x['y'], x['count'], x['home_radius'])

	return
	
	var gen_map = ENEMY_GEN_MAP['ENEMY_01']
	var attempting_coords = getAttemptingCoords(gen_map['SPAWN_ATTEMPTS_PER_BOTTOM_PERC'])
	
	var success_spawn_coords = []    
	for coord in attempting_coords:
		
		var attempt_y = coord[0]
		var attempt_x = coord[1]
		
		var near_coords_dist = util.getRandomInt(
			gen_map['NEAR_COORDS_DIST']['MIN'], gen_map['NEAR_COORDS_DIST']['MAX']
		)
		
		var near_coords = getNearCoords(attempt_x, attempt_y, near_coords_dist)
		
		if isNearSolidTiles(near_coords):  continue
		if isTooCloseToOtherSpawn(near_coords, success_spawn_coords):  continue
		
		success_spawn_coords += [[attempt_y, attempt_x]]
		
		var count_per_swarm = util.getRandomInt(
			gen_map['COUNT_PER_SWARM']['MIN'], gen_map['COUNT_PER_SWARM']['MAX']
		)
		var home_radius = util.getRandomInt(
			gen_map['HOME_RADIUS']['MIN'], gen_map['HOME_RADIUS']['MAX']
		)
		
		genEnemy01Swarm(attempt_x, attempt_y, count_per_swarm, home_radius)
		setMiniTileMapEnemyPos(attempt_x, attempt_y)


func genEnemy02s() -> void:
	
	""" for manual placement testing """
#	for x in [
#		{'pos': Vector2(580, 2260), 'segment_count': 20},
#	]:  genEnemy02(x['pos'], x['segment_count'])
	
	return
	
	var gen_map = ENEMY_GEN_MAP['ENEMY_02']
	var attempting_coords = getAttemptingCoords(gen_map['SPAWN_ATTEMPTS_PER_BOTTOM_PERC'])
	
	var success_spawn_coords = []    
	for coord in attempting_coords:
		
		var attempt_y = coord[0]
		var attempt_x = coord[1]
		
		var near_coords_dist = util.getRandomInt(
			gen_map['NEAR_COORDS_DIST']['MIN'], gen_map['NEAR_COORDS_DIST']['MAX']
		)
		
		var near_coords = getNearCoords(attempt_x, attempt_y, near_coords_dist)
		
		if isNearSolidTiles(near_coords):  continue
		if isTooCloseToOtherSpawn(near_coords, success_spawn_coords):  continue
		
		success_spawn_coords += [[attempt_y, attempt_x]]
		
		var segment_count = util.getRandomInt(
			gen_map['SEGMENT_COUNT']['MIN'], gen_map['SEGMENT_COUNT']['MAX']
		)
		
		var enemy_pos = Vector2(attempt_x * tile_map.cell_size[0], attempt_y * tile_map.cell_size[0])
		
		genEnemy02(enemy_pos, segment_count)
		
		setMiniTileMapEnemyPos(attempt_x, attempt_y)


func genEnemy03s() -> void:
	
	""" for manual placement testing """
	for x in [
		{'pos': Vector2(580, 2260), 'segment_count': 20},
	]:  genEnemy02(x['pos'], x['segment_count'])
	
#	return
	
	var gen_map = ENEMY_GEN_MAP['ENEMY_03']
	var attempting_coords = getAttemptingCoords(gen_map['SPAWN_ATTEMPTS_PER_BOTTOM_PERC'])
	
	var success_spawn_coords = []    
	for coord in attempting_coords:
		
		var attempt_y = coord[0]
		var attempt_x = coord[1]
		
		var near_coords_dist = util.getRandomInt(
			gen_map['NEAR_COORDS_DIST']['MIN'], gen_map['NEAR_COORDS_DIST']['MAX']
		)
		
		var near_coords = getNearCoords(attempt_x, attempt_y, near_coords_dist)
		
		if isNearSolidTiles(near_coords):  continue
		if isTooCloseToOtherSpawn(near_coords, success_spawn_coords):  continue
		
		success_spawn_coords += [[attempt_y, attempt_x]]
		
		var enemy_pos = Vector2(attempt_x * tile_map.cell_size[0], attempt_y * tile_map.cell_size[0])
		var enemy_dir = util.getRandomInt(0, 360)
		
		genEnemy03(enemy_pos, enemy_dir)
		
#		var inst = enemy_03.instance()
#		inst.global_position = Vector2(attempt_x * tile_map.cell_size[0], attempt_y * tile_map.cell_size[0])
#		_enemies_.add_child(inst)
		
		
		
		setMiniTileMapEnemyPos(attempt_x, attempt_y)


func genEnemy03(_pos:Vector2, _dir:int) -> void:
	var enemy_inst = enemy_03.instance()
	_enemies_.add_child(enemy_inst)
	enemy_inst.global_position = _pos
	enemy_inst.init(_dir)


####################################################################################################


func getAttemptingCoords(_per_bottom_perc_dict:Dictionary) -> Array:
	var attempting_coords = []
	for perc in _per_bottom_perc_dict.keys():
		var attempts_count = util.getRandomInt(
			_per_bottom_perc_dict[perc]['MIN'], _per_bottom_perc_dict[perc]['MAX']
		)
		var attempt_height_top = max(ctrl.safe_zone_start_height, int(ctrl.tile_map_height * (1 - perc)))
		var attempt_height_bottom = ctrl.tile_map_height - 1
		for _i in attempts_count:
			var attempt_y = util.getRandomInt(attempt_height_top, attempt_height_bottom)
			var attempt_x = util.getRandomInt(0, ctrl.tile_map_width - 1)
			attempting_coords += [[attempt_y, attempt_x]]
	return attempting_coords


func getNearCoords(_x:int, _y:int, _how_near:int) -> Array:
	var near_coords = []
	for y in range(max(_y - _how_near, 0), min(_y + _how_near, ctrl.tile_map_height - 1)):
		for x in range(max(_x - _how_near, 0), min(_x + _how_near, ctrl.tile_map_width - 1)):
			near_coords += ['%s,%s' % [y, x]]
	return near_coords


func isNearSolidTiles(_near_coords:Array) -> bool:
	for coord in _near_coords:
		if data.tiles[coord]['tile_level'] != 0:  return true
	return false


func isTooCloseToOtherSpawn(_near_coords:Array, _success_spawn_coords:Array) -> bool:
	for success_spawn_coord in _success_spawn_coords:
		if success_spawn_coord in _near_coords:
			return true
	return false


func setMiniTileMapEnemyPos(_x:int, _y:int, _buffer:int=1) -> void:
	for y in range(max(_y - _buffer, 0), min(_y + _buffer, ctrl.tile_map_height - 1)):
		for x in range(max(_x - _buffer, 0), min(_x + _buffer, ctrl.tile_map_width - 1)):
			mini_tile_map.set_cell(x, y, 5)


func genEnemy01Swarm(_home_x_tile:int, _home_y_tile:int, _enemy_count:int, _home_radius_tile:int) -> void:
	var enemy_pos = Vector2(_home_x_tile * tile_map.cell_size[0], _home_y_tile * tile_map.cell_size[0])
	for i in _enemy_count:
		var enemy_inst = enemy_01.instance()
		enemy_inst.global_position = enemy_pos
		enemy_inst.HOME_POS = enemy_pos
		enemy_inst.HOME_RADIUS_BY_TILE = _home_radius_tile
		_enemies_.add_child(enemy_inst)


func genEnemy02(
	_pos:Vector2, _segment_count:int, _from_split:bool=false, _spine:Array=[],
	_segments_data:Dictionary={}
) -> void:
	var enemy_inst = enemy_02.instance()
	_enemies_.add_child(enemy_inst)
	enemy_inst.global_position = _pos
	enemy_inst.init(_segment_count, _from_split, _spine, _segments_data)


















