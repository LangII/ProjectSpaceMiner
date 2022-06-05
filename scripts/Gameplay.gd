
extends Node

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var util = get_node('/root/Main/Utilities')

onready var drop = preload('res://scenes/Drop.tscn')
onready var mineral_01_texture = preload('res://sprites/tiles/mineral_01.png')
onready var mineral_02_texture = preload('res://sprites/tiles/mineral_02.png')
onready var mineral_03_texture = preload('res://sprites/tiles/mineral_03.png')

onready var DROP_TEXTURE_MAP = {
    'mineral_01': mineral_01_texture,
    'mineral_02': mineral_02_texture,
    'mineral_03': mineral_03_texture
}

#onready var SEED = util.rng.randi()
#onready var SEED = hash('1234')
onready var SEED = 3161026589

var hud = null


####################################################################################################


func _ready():
    
    print("SEED = ", SEED)
    
    util.rng.seed = SEED
    util.rng.randomize()
    
    var tile_map_logic = load('res://scenes/tiles/TileMapLogic.tscn').instance()
    tile_map_logic.noise.seed = SEED
    main.add_child(tile_map_logic)
    if tile_map_logic.mini_map_test:  return
    
    add_child(load('res://scenes/Ship.tscn').instance())
    
    hud = load('res://scenes/Hud.tscn').instance()
    add_child(hud)


####################################################################################################


func initDrop(drop_type, drop_value, pos):
    var new_drop = drop.instance()
    new_drop.get_node('Sprite').texture = DROP_TEXTURE_MAP[drop_type]
    new_drop.DROP_TYPE = drop_type
    new_drop.DROP_VALUE = drop_value
    new_drop.global_position = pos
    $Drops.add_child(new_drop)


func dropCollected(drop_type, drop_value):
    var drop_is_new = null
    if not drop_type in data.drops_collected.keys():
        data.drops_collected[drop_type] = {'count': 1, 'value': drop_value}
        drop_is_new = true
    else:
        data.drops_collected[drop_type]['count'] += 1
        data.drops_collected[drop_type]['value'] += drop_value
        drop_is_new = false
    hud.dropCollected(drop_is_new, drop_type, 1, drop_value)
#    print("data.drops_collected = ", data.drops_collected)
    

















