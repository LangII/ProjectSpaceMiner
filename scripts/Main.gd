
extends Node

var gameplay

func _ready():
    
#    var mod = 9 % 360
#
#    print("mod = ", mod)
#
#    return 
    
    ################################################################################################
    
    gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

####################################################################################################

func _process(_delta):
    
    if Input.is_action_just_pressed('test'):
        
        var enemy_02 = get_node('Gameplay/Enemies/Enemy02')
        
        if enemy_02.turn_dir == +1:  enemy_02.turn_dir = -1
        else:  enemy_02.turn_dir = +1
        
#        print("enemy_02.spine = ", enemy_02.spine)
        
#        print("enemy_02.spine = ", enemy_02.spine)
        
#        var enemy_inst = load('res://scenes/Enemy02.tscn').instance()
#        enemy_inst.global_position = Vector2(600, 300)
#        gameplay.get_node('Enemies').add_child(enemy_inst)
#        enemy_inst
        
#        var enemy_02 = $Gameplay/Enemies/Enemy02
#        print("")
#        print("enemy_02.spine = ", enemy_02.spine)
#        print("enemy_02.global_position = ", enemy_02.global_position)
#        print("enemy_02.get_node('Ignored/Body01').global_position = ", enemy_02.get_node('Ignored/Body01').global_position)
#        print("enemy_02.get_node('Ignored/Tail').global_position = ", enemy_02.get_node('Ignored/Tail').global_position)




