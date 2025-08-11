
extends 'res://scripts/tiles/d-FixtureTileMapLogic.gd'

func _ready():
	
	gameplay.add_child(tile_map)
	
	gameplay.add_child(mini_tile_map)
	
	gameplay.add_child(destruct_tile_map)
	
	gameplay.add_child(mineral_tile_map)
	
	setNoiseParams()
	
	initTileDataContainer()
	
	tileDataLoop(funcref(self, 'setTileDataNoise'), false, true)

	setBoarderWallFrom1dNoise()
	
	# fade out for top air
	updateNoiseWithVertLinearFade(0, SAFE_ZONE_START_HEIGHT, 0, 1)
	
	tileDataLoop(funcref(self, 'setTileDataTileLevelAndTileCode'), true, false)
	
	tileDataLoop(funcref(self, 'setTileMapCells'), false, true)
	
	generateAllTypesMineralVeins()
	
	
	
	generateMotherShipTerraform()
#
#	generateMotherShipFixture()
	
	
	
	for k in data.tiles.keys():
		var y = data.tiles[k]['y']
		var x = data.tiles[k]['x']



		"""

		i need to go through each of the following functions and determine how tile['is_fixture']
		gets worked into them

		then will need to do the same with areaTileUpdateFromCol()

		"""

#		if data.tiles[k]['is_fixture']:  continue



		setTileDataHealth(k)

		setTileDataDestructs(k)

		setTileDataNeighborPos(k, y, x)

		setTileDataNeighborTileLevelTileCodeIsFixture(k)

		setTileDataIsCol(k)

		setTileDataAirCount(k)

		setTileDataAirDirCode(k)

		setTileDataEdge(k)

		setTileDataEdgeCount(k)

		setTileDataEdgeDirCode(k)

		setTileMapCells(k, y, x)

		updateTileMapColTile(k, y, x)

		updateTileMapEdgeTile(k, y, x)

	updateBoarderWall()

	updateAirBoarderWall()

	for k in data.tiles.keys():
		if data.tiles[k]['mineral_type']:
			setMiniTileMapMineralPos(data.tiles[k]['x'], data.tiles[k]['y'])
	
	
	
	
	
	
	##################################
	
	
#	var base_width = 6
#	var chosen_landing_site = data.mothership_landing_site
#	for x in range(chosen_landing_site['x'], chosen_landing_site['x'] + base_width):
#		for y in range(chosen_landing_site['starting_y'], chosen_landing_site['ending_y']):
#			setMiniTileMapStructurePos(x, y)
	
	
	
	
	
	
