
extends Node

func _ready():
    
#    var item = get_node('Utilities').getRandomItemFromArrayWithWeight(
#        ['a', 'b', 'c', 'd'],
#        [0.10, 0.20, 0.20, 0.50]
#    )
#
#    print("")
#    print("item = ", item)
#
#    return
    
    ################################################################################################
    
    var gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

####################################################################################################

func _process(_delta):
    
    if Input.is_action_pressed('test'):
        
        var ship = get_node('Gameplay/Ship')
        print("ship.global_position = ", ship.global_position)
