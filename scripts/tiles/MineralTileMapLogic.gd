

"""

-------------------
LOW PRIORITY TO DOS
-------------------

2024-01-31
While testing for Enemy03 development, I wanted there to be no Mineral generation.  So I set all
VEIN_SIZE_MIN and VEIN_SIZE_MAX values to 0.  There was an odd result.  There was a dramatic decrease
in Mineral generation, however the unexpected behavior was that there were still a couple here and
there that were generated.  Investigate why.

"""


extends 'res://scripts/tiles/BaseTileMapLogic.gd'


var MINERAL_MAP = {
	'mineral_01': {
		'TILE_CODE': 0, 'TILE_LEVELS': [1], 'VEIN_ATTEMPTS': 250, 'DROP_VALUE_MIN': 1, 'DROP_VALUE_MAX': 3,
		'VEIN_SIZE_MIN': 4, 'VEIN_SIZE_MAX': 12
	},
	'mineral_02': {
		'TILE_CODE': 1, 'TILE_LEVELS': [1], 'VEIN_ATTEMPTS': 150, 'DROP_VALUE_MIN': 1, 'DROP_VALUE_MAX': 3,
		'VEIN_SIZE_MIN': 2, 'VEIN_SIZE_MAX': 8
	},
	'mineral_03': {
		'TILE_CODE': 2, 'TILE_LEVELS': [2], 'VEIN_ATTEMPTS': 150, 'DROP_VALUE_MIN': 1, 'DROP_VALUE_MAX': 3,
		'VEIN_SIZE_MIN': 2, 'VEIN_SIZE_MAX': 8
	},
}


####################################################################################################
""" _ready FUNCS """


func generateAllTypesMineralVeins():
	for type in MINERAL_MAP.keys():  generateMineralVeins(type)


func generateMineralVeins(mineral_type):
	
	var mineral_dict = MINERAL_MAP[mineral_type]
	
	for n in mineral_dict['VEIN_ATTEMPTS']:
		
		var vein_start_y = util.getRandomInt(1, TILE_MAP_HEIGHT - 2)
		var vein_start_x = util.getRandomInt(1, TILE_MAP_WIDTH - 2)
		var vein_start_k = '%s,%s' % [vein_start_y, vein_start_x]
		
		if (
			not data.tiles[vein_start_k]['tile_level'] in mineral_dict['TILE_LEVELS']
			or data.tiles[vein_start_k]['is_mineral']
		):  continue
		
		setMineralTile(vein_start_k, vein_start_y, vein_start_x, mineral_dict, mineral_type)
		
		var prev_y = vein_start_y
		var prev_x = vein_start_x
		var prev_k = '%s,%s' % [prev_y, prev_x]
		var cur_y = null
		var cur_x = null
		var cur_k = null
		
		var cur_vein_ks = []
		for v in util.getRandomInt(mineral_dict['VEIN_SIZE_MIN'], mineral_dict['VEIN_SIZE_MAX']):
			
			cur_y = prev_y + util.getRandomInt(-1, +1)
			cur_x = prev_x + util.getRandomInt(-1, +1)
			cur_k = '%s,%s' % [cur_y, cur_x]
			
			if (
				cur_y <= 0
				or cur_y >= TILE_MAP_WIDTH - 1
				or cur_x <= 0
				or cur_x >= TILE_MAP_HEIGHT - 1
				or not data.tiles[cur_k]['tile_level'] in mineral_dict['TILE_LEVELS']
				or data.tiles[cur_k]['is_mineral']
				or cur_k in cur_vein_ks
				or cur_k == prev_k
			):  continue
			
			setMineralTile(cur_k, cur_y, cur_x, mineral_dict, mineral_type)
			
			cur_vein_ks += [cur_k]
			
			prev_y = cur_y
			prev_x = cur_x
			prev_k = cur_k
			cur_y = null
			cur_x = null
			cur_k = null


func setMineralTile(k, y, x, _dict, _type):
	data.tiles[k]['is_mineral'] = true
	data.tiles[k]['mineral_type'] = _type
	data.tiles[k]['mineral_drop_value'] = util.getRandomInt(_dict['DROP_VALUE_MIN'], _dict['DROP_VALUE_MAX'])
	mineral_tile_map.set_cell(x, y, _dict['TILE_CODE'])



func setMiniTileMapMineralPos(_x:int, _y:int, _buffer:int=1) -> void:
	for y in range(max(_y - _buffer, 0), min(_y + _buffer, ctrl.tile_map_height - 1)):
		for x in range(max(_x - _buffer, 0), min(_x + _buffer, ctrl.tile_map_width - 1)):
			mini_tile_map.set_cell(x, y, 4)







