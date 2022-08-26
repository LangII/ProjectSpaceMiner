
extends Node

func _ready():
    
#    var testing = int(1.75)
#
#    print("testing = ", testing)
#
#    return 
    
    ################################################################################################
    
    var gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

####################################################################################################

func _process(_delta):
    
    if Input.is_action_pressed('test'):
        
#        var ship = get_node('Gameplay/Ship')
#        print("ship.global_position = ", ship.global_position)
        
        var data = get_node('Data')
        print("data.tiles = ", data.tiles)
