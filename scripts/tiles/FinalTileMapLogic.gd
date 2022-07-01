
extends 'res://scripts/tiles/MineralTileMapLogic.gd'

func _ready():
    
    gameplay.add_child(tile_map)
    
    if mini_map_test:  gameplay.add_child(mini_tile_map)
    
    gameplay.add_child(destruct_tile_map)
    
    gameplay.add_child(mineral_tile_map)
    
    setNoiseParams()
    
    initTileDataContainer()
        
    tileDataLoop(funcref(self, 'setTileDataNoise'), false, true)

    setBoarderWallFrom1dNoise()
    
    # fade out for top air
    updateNoiseWithVertLinearFade(0, 50, 0, 1)
    
    tileDataLoop(funcref(self, 'setTileDataTileLevelAndTileCode'), true, false)
    
    if mini_map_test:
        tileDataLoop(funcref(self, 'setTileMapCells'), false, true)
        gameplay.remove_child(tile_map)
        gameplay.remove_child(destruct_tile_map)
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
    

