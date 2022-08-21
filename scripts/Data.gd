
extends Node

"""
{
    0,0: {
        air_count: Null,
        air_dir_code: ,
        destruct_tile_code: Null,
        destruct_tile_level: 0,
        edge_count: Null,
        edge_dir_code: ,
        global_pos_center: (10, 10),
        health: Null,
        is_col: False,
        is_edge: False,
        is_mineral: False,
        max_health: Null,
        mineral_drop_value: 0,
        mineral_type: Null,
        neighbors_pos: {
            E: [0, 1],
            N: Null,
            S: [1, 0],
            W: Null
        },
        neighbors_tile_code: {
            E: 0,
            N: Null,
            S: 0,
            W: Null
        },
        neighbors_tile_level: {
            E: 0,
            N: Null,
            S: 0,
            W: Null
        },
        noise: 0,
        pos: [0, 0],
        tile_code: 2,
        tile_level: 0,
        x: 0,
        y: 0
    }
}
"""
var tiles = {}

var drops_collected = {}
