
extends KinematicBody2D

onready var tile_map_logic = get_node('/root/Main/TileMapLogic')
onready var tile_map = get_node('/root/Main/TileMap')

var COLLISION_NORMAL_CLAMP = 0.01
var SPEED = 450
var DMG = 20

var velocity = Vector2()

####################################################################################################

func _process(delta):
    
    var collision = move_and_collide(velocity * delta)
    
    if collision and collision.collider == tile_map:
        
        collidedWithTileMap(collision)

####################################################################################################

func start(pos, dir):
    position = pos
    rotation = dir.angle() + deg2rad(90)
    velocity = dir * SPEED


func collidedWithTileMap(col):
    var mod_normal = col.normal.clamped(COLLISION_NORMAL_CLAMP)
    var tile_pos = tile_map.world_to_map(col.position - mod_normal)
    tile_map_logic.tileTakesDmg(tile_pos, DMG)
    queue_free()

####################################################################################################

func _on_QueueFreeTimer_timeout():
    queue_free()



