


extends 'res://scripts/tiles/TileMapLogic3_Mineral.gd'



onready var _interactive_terrain_ = gameplay.get_node('InteractiveTerrain')



####################################################################################################
""" MotherShip VARS """



onready var mothership_landing_platform_scn = preload('res://scenes/MothershipLandingPlatform.tscn')

onready var MOTHERSHIP_SCALE = {}
onready var MOTHERSHIP_BASE_WIDTH = null
onready var MOTHERSHIP_LANDING_SITES = []
onready var MOTHERSHIP_LANDING_SITES_SELECTION_POOL = []
onready var MOTHERSHIP_CHOSEN_LANDING_SITE = {}
onready var MOTHERSHIP_TERRAFORM_NOISE = 0.25
onready var GRADE_A_TERRAFORM_DEPTH = 1



####################################################################################################
"""  Mothership FUNCS  """



func generateMothership() -> void:
	
	setMothershipScale()
	
	setLandingSites(MOTHERSHIP_BASE_WIDTH)
	
	"""
	select_by_manual_int
	select_from_is_in_safe_zones
	select_from_terraform_grades
	"""
#	chooseLandingSite(null, [false, true], ['A', 'C'])
	
	chooseLandingSite(18, [], [])
#	chooseLandingSite(null, [false, true], ['A', 'C', 'F'])
	
	terraformSite(
		MOTHERSHIP_CHOSEN_LANDING_SITE['x'],
		MOTHERSHIP_CHOSEN_LANDING_SITE['x'] + MOTHERSHIP_BASE_WIDTH,
		MOTHERSHIP_CHOSEN_LANDING_SITE['starting_y'],
		MOTHERSHIP_CHOSEN_LANDING_SITE['ending_y'],
		MOTHERSHIP_TERRAFORM_NOISE
	)
	
	generateMothershipFixture(
		MOTHERSHIP_CHOSEN_LANDING_SITE['anchor_x'],
		MOTHERSHIP_CHOSEN_LANDING_SITE['anchor_y']
	)
	
	generateMothershipLandingPlatform(
		MOTHERSHIP_CHOSEN_LANDING_SITE['anchor_x'],
		MOTHERSHIP_CHOSEN_LANDING_SITE['anchor_y']
	)



func setMothershipScale() -> void:
	var ms_tile_data_xs = []
	var ms_tile_data_ys = []
	for tile_data in MOTHERSHIP_TILE_DATA:
		ms_tile_data_xs += [tile_data['x']]
		ms_tile_data_ys += [tile_data['y']]
	MOTHERSHIP_SCALE = {'x': ms_tile_data_xs.max() + 1, 'y': ms_tile_data_ys.max() + 1}
	MOTHERSHIP_BASE_WIDTH = MOTHERSHIP_SCALE['x']



func setLandingSites(_base_width:int) -> void:
	"""
	landing_site = {
		'x': 0,
		'rows': [],  # tile_codes of tiles in row
		'starting_y': 0,
		'ending_y': 0,
		'is_in_safe_zone': false,
		'terraform_depth': 0,
		'terraform_grade': 'F'
	}
	"""
	for x in range(TILE_MAP_WIDTH - _base_width):
		var landing_site = {'x': x, 'starting_y': null}
		landing_site['rows'] = []
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
				landing_site['is_in_safe_zone'] = landing_site['ending_y'] <= SAFE_ZONE_START_HEIGHT
				if landing_site['terraform_depth'] > _base_width:
					landing_site['terraform_grade'] = 'F'	# grade 'F' are landing_sites with terraform_grade higher
															# than the Mothership Base Width
				elif landing_site['terraform_depth'] <= GRADE_A_TERRAFORM_DEPTH:
					landing_site['terraform_grade'] = 'A'	# grade 'A' are landing_sites with terraform_grade less than
															# or equal to the manually set "Grade A" depth
				else:
					landing_site['terraform_grade'] = 'C'	# grade 'C' are landing_sites that are not grade F nor grade A
				MOTHERSHIP_LANDING_SITES += [landing_site]
				break



func thisRowHasAir(_row:Array) -> bool:
	for tile_code in _row:
		if tile_code <= 2:  return true
	return false



func thisRowIsAllAir(_row:Array) -> bool:
	for tile_code in _row:
		if tile_code >= 3:  return false
	return true



func chooseLandingSite(
	_select_by_manual_int=null,
	_select_from_is_in_safe_zones=[false, true],
	_select_from_terraform_grades=['A', 'C', 'F']
) -> void:
	var chosen_landing_site = {}
	# select by manual selection
	if _select_by_manual_int:
		chosen_landing_site = MOTHERSHIP_LANDING_SITES[_select_by_manual_int]
	# select by pool selection
	if not chosen_landing_site:
		# build MOTHERSHIP_LANDING_SITES_SELECTION_POOL
		for ls in MOTHERSHIP_LANDING_SITES:
			if (
				ls['terraform_grade'] in _select_from_terraform_grades
				and ls['is_in_safe_zone'] in _select_from_is_in_safe_zones
			):
				MOTHERSHIP_LANDING_SITES_SELECTION_POOL += [ls]
		MOTHERSHIP_LANDING_SITES_SELECTION_POOL = util.getUniqueFromArray(
			MOTHERSHIP_LANDING_SITES_SELECTION_POOL
		)
		# choose landing site
		chosen_landing_site = util.getRandomItemFromArray(MOTHERSHIP_LANDING_SITES_SELECTION_POOL)
	# add 'anchor_' keys to chosen_landing_site
	chosen_landing_site['anchor_x'] = chosen_landing_site['x']
	chosen_landing_site['anchor_y'] = chosen_landing_site['starting_y'] - MOTHERSHIP_SCALE['y']
	MOTHERSHIP_CHOSEN_LANDING_SITE = chosen_landing_site



#	var selection_pool_xs = []
#	for ls in MOTHERSHIP_LANDING_SITES_SELECTION_POOL:
#		selection_pool_xs += [ls['x']]
#	print("\nselection_pool_xs = ", selection_pool_xs)
#	print("\nlen(selection_pool_xs) = ", len(selection_pool_xs))



func generateMothershipFixture(_top_left_x:int, _top_left_y:int) -> void:
	for ms_tile in MOTHERSHIP_TILE_DATA:
		var x = ms_tile['x'] + _top_left_x
		var y = ms_tile['y'] + _top_left_y
		var k = '%s,%s' % [y, x]
		data.tiles[k]['is_fixture'] = true
		data.tiles[k]['tile_code'] = ms_tile['tile_code']
		data.tiles[k]['mini_tile_code'] = ms_tile['mini_tile_code']
		data.tiles[k]['fixture_id'] = ms_tile['fixture_id']
		tile_map.set_cell(
			x, y, ms_tile['tile_code'], ms_tile['tile_map_set_cell_flip_x'],
			ms_tile['tile_map_set_cell_flip_y'], ms_tile['tile_map_set_cell_transpose']
		)
		mini_tile_map.set_cell(x, y, ms_tile['mini_tile_code'])



func generateMothershipLandingPlatform(_top_left_x:int, _top_left_y:int) -> void:
	var mothership_landing_platform = mothership_landing_platform_scn.instance()
	_interactive_terrain_.add_child(mothership_landing_platform)
	mothership_landing_platform.global_position = util.convTileMapPosToGlobalPos(
		Vector2(_top_left_x, _top_left_y),
		'top_left'
	)



####################################################################################################
""" terraform FUNCS """



func terraformSite(
	_starting_x:int, _ending_x:int, _starting_y:int, _ending_y:int, _noise:float
) -> void:
	for x in range(_starting_x, _ending_x):
		for y in range(_starting_y, _ending_y):
			var k = '%s,%s' % [y, x]
			data.tiles[k]['noise'] = _noise
			data.tiles[k]['is_terraform'] = true
			setTileDataTileLevelAndTileCode(k)
			setTileMapCells(k, y, x)




