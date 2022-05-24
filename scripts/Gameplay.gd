
extends Node

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var util = get_node('/root/Main/Utilities')

onready var drop = preload('res://scenes/Drop.tscn')
onready var mineral_01_texture = preload('res://sprites/tiles/mineral_01.png')

onready var DROP_TEXTURE_MAP = {
    'mineral_01': mineral_01_texture
}


####################################################################################################


func _ready():
    
    var tile_map_logic = load('res://scenes/tiles/TileMapLogic.tscn').instance()
    main.add_child(tile_map_logic)
    if tile_map_logic.mini_map_test:  return
    
    add_child(load('res://scenes/Ship.tscn').instance())


####################################################################################################


func initDrop(drop_type, drop_value, pos):
    var new_drop = drop.instance()
    new_drop.get_node('Sprite').texture = DROP_TEXTURE_MAP[drop_type]
    new_drop.DROP_TYPE = drop_type
    new_drop.DROP_VALUE = drop_value
    new_drop.global_position = pos
    $Drops.add_child(new_drop)


func dropCollected(drop_type, drop_value):
    if not drop_type in data.drops_collected.keys():  data.drops_collected[drop_type] = drop_value
    else:  data.drops_collected[drop_type] += drop_value
    print("data.drops_collected = ", data.drops_collected)

















