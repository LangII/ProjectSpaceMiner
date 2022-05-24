
extends Node

func _ready():
    
#    for _n in 10:
#        print($Utilities.getRandomInt(0, 1))
#
#    return
    
    ################################################################################################
    
    var gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

