
extends Node

var gameplay

func _ready():
    
#    var test = util.convTileMapPosToGlobalPos(Vector2())
#
#    print("test = ", test
#
#    return 
    
    ################################################################################################
    
    gameplay = load('res://scenes/Gameplay.tscn').instance()
    add_child(gameplay)
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

####################################################################################################

func _process(_delta):
    
    if Input.is_action_just_pressed('test'):
        
        var enemy = get_node('Gameplay/Enemies/Enemy02')
        
        print("\nname =                     ", enemy.name)
        print("global_position =              ", enemy.global_position)
        print("target =                       ", enemy.target)
        print("is_touching_wall =             ", enemy.is_touching_wall)
        print("angle_to_target =              ", enemy.angle_to_target)
        print("is_approaching_target =        ", enemy.is_approaching_target)
        print("angle_to_target_is_expanding = ", enemy.angle_to_target_is_expanding)
        
#        var test_x = 10
#        var test_y = 50
#        var data_tiles_value = get_node('Data').tiles['%s,%s' % [test_y, test_x]]
#        var test_vector = Vector2(data_tiles_value['x'], data_tiles_value['y'])
#
#        var test = get_node('Utilities').convTileMapPosToGlobalPos(test_vector)
#
#        print("test_x =      ", test_x)
#        print("test_y =      ", test_y)
#        print("test_vector = ", test_vector)
#        print("test =        ", test)
        
#        var enemy_02 = get_node('Gameplay/Enemies/Enemy02')
        
#        enemy_02.changeTurnDir()
        
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




