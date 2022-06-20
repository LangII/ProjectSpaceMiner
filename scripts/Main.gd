
extends Node

func _ready():
    
#    var new_vector = Vector2(50, 50).move_toward(Vector2(50, 100), 10)
#    print("new_vector = ", new_vector)
#
#    return
    
    ################################################################################################
    
    var gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

