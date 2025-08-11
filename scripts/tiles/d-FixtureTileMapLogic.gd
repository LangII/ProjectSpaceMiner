


extends 'res://scripts/tiles/c-MineralTileMapLogic.gd'



#onready var main = get_node('/root/Main')
#onready var ctrl = get_node('/root/Main/Controls')
#onready var data = get_node('/root/Main/Data')
#onready var util = get_node('/root/Main/Utilities')
#onready var gameplay = get_node('/root/Main/Gameplay')
#
#onready var tile_map_logic = get_node('/root/Main/Gameplay/TileMapLogic')
##onready var enemy_gen_logic = get_node('/root/Main/Gameplay/EnemyGenLogic')
#
#onready var mini_tile_map = get_node('/root/Main/Gameplay/MiniTileMap')


onready var CHOOSE_LANDING_SITE_ATTEMPTS_BEFORE_CHOOSE_ANY = 100

onready var MOTHERSHIP_SCALE = {'x': 4, 'y': 3}



onready var mothership_landing_platform_scn = preload('res://scenes/MothershipLandingPlatform.tscn')
onready var _interactive_terrain_ = gameplay.get_node('InteractiveTerrain')




####################################################################################################


func generateMotherShipTerraform():
	
#	print("starting generateMotherShipTerraform()")
	
	var base_width = 6
	var grade_A_terraform_depth = 1
	var landing_sites = getLandingSites(base_width, grade_A_terraform_depth)
	
#	data.mothership_landing_sites = landing_sites
	
	var chosen_landing_site = chooseLandingSite(landing_sites)
	
#	print("chosen_landing_site = ", chosen_landing_site)
	
#	for landing_site in landing_sites:
#
##		if not landing_site['is_in_safe_zone']:  continue
##		if landing_site['terraform_grade'] != 'C':  continue
#		if landing_site['x'] != 21:  continue
#
##		tile_map_logic.

	for x in range(chosen_landing_site['x'], chosen_landing_site['x'] + base_width):
		for y in range(chosen_landing_site['starting_y'], chosen_landing_site['ending_y']):

			var k = '%s,%s' % [y, x]

			data.tiles[k]['noise'] = 0.25

			data.tiles[k]['is_terraform'] = true
#			data.tiles[k]['has_fixture_dependency'] = true

#			data.tiles[k]['tile_level'] = 1
#			data.tiles[k]['tile_code'] = 3
#			data.tiles[k]['mini_tile_code'] = 1
			
#			tile_map_logic.setTileDataNeighborTileLevelTileCodeIsFixture(k)
			setTileDataTileLevelAndTileCode(k)

#			tile_map_logic.setTileMapCells(k, y, x)
			setTileMapCells(k, y, x)
			
#			setMiniTileMapStructurePos(x, y)
			
	var mothership_anchor_x = chosen_landing_site['x']
	var mothership_anchor_y = chosen_landing_site['starting_y'] - MOTHERSHIP_SCALE['y']
	
	
	
	generateMotherShipFixture(mothership_anchor_x, mothership_anchor_y)





func generateMotherShipFixture(_top_left_x:int, _top_left_y:int) -> void:
	
	for ms_tile in MOTHERSHIP_TILE_DATA:
		
		var x = ms_tile['x'] + _top_left_x
		var y = ms_tile['y'] + _top_left_y
		var k = '%s,%s' % [y, x]
		
#		data.tiles[k]['noise'] = 0.75
		
#		data.tiles[k]['tile_level'] = FIXTURE_TILE_LEVEL
		
		data.tiles[k]['is_fixture'] = true
		data.tiles[k]['tile_code'] = ms_tile['tile_code']
#		data.tiles[k]['tile_code'] = 4  # 8  # 14
		data.tiles[k]['mini_tile_code'] = ms_tile['mini_tile_code']
		data.tiles[k]['fixture_id'] = ms_tile['fixture_id']
		
#		setTileDataTileLevelAndTileCode(k)

#		setTileMapCells(k, y, x)
		
#		setMiniTileMapStructurePos(x, y)

		tile_map.set_cell(
			x, y, ms_tile['tile_code'], ms_tile['tile_map_set_cell_flip_x'],
			ms_tile['tile_map_set_cell_flip_y'], ms_tile['tile_map_set_cell_transpose']
		)
		mini_tile_map.set_cell(x, y, ms_tile['mini_tile_code'])
	
	
	
	generateMothershipLandingPlatform(_top_left_x, _top_left_y)






func generateMothershipLandingPlatform(_top_left_x:int, _top_left_y:int) -> void:
	
	
	"""
	var enemy_inst = enemy_02.instance()
	_enemies_.add_child(enemy_inst)
	enemy_inst.global_position = _pos
	enemy_inst.init(_segment_count, _from_split, _spine, _segments_data)
	"""
	
	var mothership_landing_platform = mothership_landing_platform_scn.instance()
	_interactive_terrain_.add_child(mothership_landing_platform)
	mothership_landing_platform.global_position = util.convTileMapPosToGlobalPos(Vector2(_top_left_x, _top_left_y), 'top_left')
	
	
	




"""

TODOS:

create the MOTHERSHIP LANDING PLATFORM

the LANDING PLATFORM will be a new gameplay object:  INTERACTIVE TERRAIN

gameplay objects:
	Enemies
	Projectiles
	Drops
	InteractiveTerrain

for now, INTERACTIVE TERRAIN are side-effects or conditions of FIXTURES (and as of now, the only Fixture
is Mothership, so the only InteractiveTerrain will be the Mothership's LandingPlatform)

###

this Mothership - LandingPlatform - InteractiveTerrain will be made up of:
	
	- sensing 2d Area Node, to sense for when Ship is near
	
		- when Ship is near, activate "Ship Is Approaching Mode"
		
			- when Ship Is Approaching the Landing Platform will extend up to indicate that the Mothership
			is now ready to "accept" the Ship
			
			- then when Ship Collides with Landing Platform, LP will detect Ship's Force, Dir, Angle, etc to
			determine if Ship Landed "softly" enough.
			
				- if Ship Collides too hard, bad dir, bad angle, then the Ship does damage to the Mothership
				and Ship has to approach again
			

###

MVP is to only have a LandingPlatform, that extends up when Ship is inside Approach Zone, when Ship
successfully Lands, LandingPlatform retracts back down (bringing Ship with it), and trigger Level End Sequence
	- including any other notes above.  this note here is for scope creep purposes, to indicate where
	work stops for MVP

###

for SHIP LANDING SEQUENCE...  need to force Ship controls to 'classic-asteroids'
	
	- to do this i need to make it an option in midgame controls to toggle between 'shuffle_board' and
	'classic_asteroids' Ship controls
	
	- this will also require an update to the Hud.  during Landing Sequence, the Hud needs to display
	Ship Landing Accuracy

###

Hud updates:

- needs an Alert Container

	- current Alert needs:
		Landing Sequence Start
		Ship Controls Change

"""





####################################################################################################



func chooseLandingSite(_landing_sites:Array) -> Dictionary:
	
	var chosen_landing_site = {}
	
#	chosen_landing_site = _landing_sites[21]
	
	if not chosen_landing_site:
		
		var depth1_landing_sites = []
		for ls in _landing_sites:
			if ls['terraform_depth'] < 6:  depth1_landing_sites += [ls]
		_landing_sites = depth1_landing_sites
		
		chosen_landing_site = util.getRandomItemFromArray(_landing_sites)
	
#	data.mothership_landing_site = chosen_landing_site
	
	return chosen_landing_site




func getLandingSites(_base_width:int, _grade_A_terraform_depth:int) -> Array:
	"""
	landing_site = {
		'x': 0,
		'rows': [],  # tile_codes of tiles in row
		'starting_y': 0,
		'ending_y': 0,
		'is_in_safe_zone': false,
		'terraform_depth': 0,
		'terraform_depth_grade': 'F'
	}
	"""
	var landing_sites = []
#	for x in range(tile_map_logic.TILE_MAP_WIDTH - _base_width):
	for x in range(TILE_MAP_WIDTH - _base_width):
		var landing_site = {'x': x, 'starting_y': null}
		landing_site['rows'] = []
#		for y in range(tile_map_logic.TILE_MAP_HEIGHT):
		for y in range(TILE_MAP_HEIGHT):
			# get this_rows_tile_codes
			var this_rows_tile_codes = []
			for this_row_next_x in range(x, x + _base_width):
				this_rows_tile_codes += [data.tiles['%s,%s' % [y, this_row_next_x]]['tile_code']]
			if not thisRowIsAllAir(this_rows_tile_codes):
				if landing_site['starting_y'] == null:  landing_site['starting_y'] = y
				landing_site['rows'] += [this_rows_tile_codes]
			if not thisRowHasAir(this_rows_tile_codes):
				landing_site['ending_y'] = y
				landing_site['terraform_depth'] = landing_site['ending_y'] - landing_site['starting_y']
#				landing_site['is_in_safe_zone'] = landing_site['ending_y'] <= tile_map_logic.SAFE_ZONE_START_HEIGHT
				landing_site['is_in_safe_zone'] = landing_site['ending_y'] <= SAFE_ZONE_START_HEIGHT
				if landing_site['terraform_depth'] > _base_width:
					landing_site['terraform_grade'] = 'F'	# grade 'F' are landing_sites with terraform_grade higher
															# than landing_site base_width
				elif landing_site['terraform_depth'] <= _grade_A_terraform_depth:
					landing_site['terraform_grade'] = 'A'	# grade 'A' is "flattest" landing_site because it only has
															# max 2 layers (0 and 1) of depth
				else:
					landing_site['terraform_grade'] = 'C'	# grade 'C' are landing_sites with depth between 3 layers
															# and {landing_site base_width} layers
				landing_sites += [landing_site]
				break
	return landing_sites


func thisRowHasAir(_row:Array) -> bool:
	for tile_code in _row:
		if tile_code <= 2:  return true
	return false


func thisRowIsAllAir(_row:Array) -> bool:
	for tile_code in _row:
		if tile_code >= 3:  return false
	return true


func setMiniTileMapStructurePos(_x:int, _y:int, _buffer:int=1) -> void:
#	for y in range(max(_y - _buffer, 0), min(_y + _buffer, tile_map_logic.TILE_MAP_HEIGHT - 1)):
#		for x in range(max(_x - _buffer, 0), min(_x + _buffer, tile_map_logic.TILE_MAP_WIDTH - 1)):
	for y in range(max(_y - _buffer, 0), min(_y + _buffer, TILE_MAP_HEIGHT - 1)):
		for x in range(max(_x - _buffer, 0), min(_x + _buffer, TILE_MAP_WIDTH - 1)):
			mini_tile_map.set_cell(x, y, 6)







####################################################################################################
""" terraform FUNCS """


func terraformSite(_start_x:int, _start_y:int, _end_x:int, _end_y:int, _tile_level:int) -> void:
	
	var tile_code = null
	var mini_tile_code = null
	var half_between_low_high = null
	for noise_settings in NOISE_SETTINGS:
		if noise_settings['TILE_LEVEL'] == _tile_level:
			tile_code = noise_settings['TILE_CODE']
			mini_tile_code = noise_settings['MINI_TILE_CODE']
			half_between_low_high = noise_settings['LOW'] + ((noise_settings['HIGH'] - noise_settings['LOW']) / 2)
			break
	
	if tile_code == null:
		util.throwError("_tile_level not in NOISE_SETTINGS")
	
#	var k = '%s,%s' % [y, x]

"""
	{
		'TILE_LEVEL': 3,
		'TILE_CODE': TILE_L03,
		'MINI_TILE_CODE': MINI_TILE_L03,
		'LOW': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_3_low]),
		'HIGH': util.coalesce([null, ctrl.basetilemaplogic_noise_settings_tile_level_3_high])
	}
"""











####################################################################################################











#		tile_map_logic.tileDataLoop(funcref(tile_map_logic, 'setTileMapCells'), false, true)
#
#		for x in range(landing_site['x'], landing_site['x'] + base_width):
#			for y in range(landing_site['starting_y'], landing_site['ending_y']):
#
#				var k = '%s,%s' % [y, x]
#
#				tile_map_logic.setTileDataHealth(k)
#				tile_map_logic.setTileDataDestructs(k)
#				tile_map_logic.setTileDataNeighborPos(k, y, x)
#				tile_map_logic.setTileDataNeighborTileLevelTileCodeIsFixture(k)
#				tile_map_logic.setTileDataCol(k)
#				tile_map_logic.setTileDataAirCount(k)
#				tile_map_logic.setTileDataAirDirCode(k)
#				tile_map_logic.setTileDataEdge(k)
#				tile_map_logic.setTileDataEdgeCount(k)
#				tile_map_logic.setTileDataEdgeDirCode(k)
#				tile_map_logic.setTileMapCells(k, y, x)
#				tile_map_logic.updateTileMapColTile(k, y, x)
#				tile_map_logic.updateTileMapEdgeTile(k, y, x)
				
				
				
#				tile_map_logic.tileTakesDmg(Vector2(x, y), 0)
				
#				"""
#
#				setTileMapCells(k, y, x)
#
#				# maybe can use this tileTakesDmg() to trigger terrain col updates
#
#				tile_map_logic.tileTakesDmg(tile_pos, 0)
#
#				"""
#
#				"""
#
#				maybe instead of trying to "build up" the terrain to meet the mothership, instead
#				i should try to give the mothership "legs" to "reach down" to the terrain
#
#				need to see how i made it so Mineral Tiles do not change shape
#
#				"""
#
#				setMiniTileMapStructurePos(x, y)
		
		
#		print("landing_site['x'] = ", landing_site['x'])
##		print("landing_site['starting_y'] = ", landing_site['starting_y'])
##		print("landing_site['ending_y'] = ", landing_site['ending_y'])
#		print("landing_site['terraform_depth'] = ", landing_site['terraform_depth'])
##		print("landing_site['is_in_safe_zone'] = ", landing_site['is_in_safe_zone'])
##		print("landing_site['terraform_grade'] = ", landing_site['terraform_grade'])
##		print("landing_site['rows'] = ", landing_site['rows'])
#		print("")
		
#		enemy_gen_logic.setMiniTileMapEnemyPos(landing_site['x'], landing_site['starting_y'])
#		enemy_gen_logic.setMiniTileMapEnemyPos(landing_site['x'] + base_width, landing_site['ending_y'])
	










