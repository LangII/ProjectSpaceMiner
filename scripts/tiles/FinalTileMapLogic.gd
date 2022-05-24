
extends 'res://scripts/tiles/MineralTileMapLogic.gd'

func _ready():
    
    main.add_child(tile_map)
    
    if mini_map_test:  main.add_child(mini_tile_map)
    
    main.add_child(destruct_tile_map)
    
    main.add_child(mineral_tile_map)
    
    randomize()
    
    noise.seed = randi()
#    noise.seed = 1234
    setNoiseParams()
    print("noise.seed = ", noise.seed)
    
    initTileDataContainer()
        
    tileDataLoop(funcref(self, 'setTileDataNoise'), false, true)

    setBoarderWallFrom1dNoise()
    
    # fade out for top air
    updateNoiseWithVertLinearFade(0, 50, 0, 1)
    
    tileDataLoop(funcref(self, 'setTileDataTileLevelAndTileCode'), true, false)
    
    if mini_map_test:
        tileDataLoop(funcref(self, 'setTileMapCells'), false, true)
        main.remove_child(tile_map)
        main.remove_child(destruct_tile_map)
        return
    
    generalAllTypesMineralVeins()
    
    for k in data.tiles.keys():
        var y = data.tiles[k]['y']
        var x = data.tiles[k]['x']
        
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
    
    updateBoarderWall()
    
    updateAirBoarderWall()
    

