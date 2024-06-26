
"""
-----
TODOS
-----

- Enemy03

-----
NOTES
-----

2023-08-20
- Thoughts for Enemy04:  Kamikaze.  They fly around fairly aimlessly, but if Ship is within range,
they target Ship and try to fly into it causing large explosion.  The balance is that they're flying
is very irradic.  Every other second they should target some other random point.  Or they're turning
is in small amounts so if 1 to 2 seconds before Enemy04 hits you you move away then Enemy04 will
miss wildly.  Basically the idea is that this enemy is a wild card.  Most people will sort of fear
this enemy but the end result should be that the enemy typically misses more times than it hits.
Maybe it can have 2 different defense states:  1 where it's just wondering around and it's defense
is super high.  But then the other is when it sees the Ship, then turns into kamikaze mode and can
be killed in 1 hit.
"""

extends Node

var gameplay

func _ready():
	
	################################################################################################
	""" TESTING """
	
#	for i in range(1, 5):
#		print("i = ", i)
	
#	var angle = rad2deg(Vector2(0, 0).angle_to(Vector2(-1, -1)))
#	print("\nangle = ", angle)
#	print("\nVector2.RIGHT = ", Vector2.RIGHT)
#	print("\nVector2.DOWN = ", Vector2.DOWN)
#	print("\nVector2.RIGHT.angle() = ", rad2deg(Vector2.RIGHT.angle()))
#	print("\nVector2.DOWN.angle() = ", rad2deg(Vector2.DOWN.angle()))
#	print("\nVector2(1, 1).angle() = ", rad2deg(Vector2(1, 1).angle()))
#	print("\nVector2(-1, -1).angle() = ", rad2deg(Vector2(-1, -1).angle()))
#
#	var util = $Utilities
#	var enemy_pos = Vector2(1, 1)
#	var ship_pos = Vector2(2, 1)
#	var angle_to_ship = util.convAngleTo360Range(rad2deg((ship_pos - enemy_pos).angle()))
#
#	print("\nangle_to_ship = ", angle_to_ship)
	
#	var testing = $Utilities.anglesDif(5.0, 355.0)
#
#	print("testing = ", Engine.get_frames_drawn())
#
#	return
	
	################################################################################################
	
	gameplay = load('res://scenes/Gameplay.tscn').instance()
	add_child(gameplay)
	
	Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

####################################################################################################

func _process(_delta):
	
	if Input.is_action_just_pressed('test'):
		
		var test_title_msg = "TEST ACTION PRESSED"
		var title_bracket = "-".repeat(len(test_title_msg))
		print("\n\n\n%s\n%s\n%s" % [title_bracket, test_title_msg, title_bracket])
		
		var get_mouse_pos_temp_node = Node2D.new()
		add_child(get_mouse_pos_temp_node)
		var global_mouse_position = get_mouse_pos_temp_node.get_global_mouse_position()
		print("\nglobal_mouse_position = ", global_mouse_position)
		get_mouse_pos_temp_node.queue_free()
		
		var mouse_pos_tile = get_node('Gameplay/TileMap').world_to_map(global_mouse_position)
		print("mouse_pos_tile = ", mouse_pos_tile)
		
#		var ship = get_node('Gameplay/Ship')
#
#		print("\nship.prev_frame_dir = ", ship.prev_frame_dir)
		
#		var enemies = get_node('Gameplay/Enemies')
		
#		var new_speed = 0
#		if enemies.get_children()[0].SPEED == 0:  new_speed = 60
#
#		for enemy in enemies.get_children():  enemy.SPEED = new_speed

#		for enemy in enemies.get_children():
#
#			if not enemy.name.replace('@', '').begins_with('Enemy02'):  continue
#
#			enemy.printDmg()
#
#			enemy.printDebugReview()
#
#			enemy.printFullSegmentsDataNMap()

#			print("\n%s:" % [enemy.name])
#
#			print("\tenemy.global_position = ", enemy.global_position)
#
#			print("\tenemy.target = ", enemy.target)
#
#			print("\nenemy.spine =\n", enemy.spine)
#
#			print("\nenemy.segments_map =\n", enemy.segments_map)
#
#			print("\nenemy.segments_data =\n", enemy.segments_data)
		
#		var enemy = get_node('Gameplay/Enemies/Enemy02')
		
#		enemy.split('Segment03')
		
#		print("\nenemy.spine =\n", enemy.spine)
		
#		print("\nenemy.segments_map =\n", enemy.segments_map)
		
#		print("\nenemy.segments_data =\n", enemy.segments_data)
		
#		enemy.target = Vector2(620, 1000)
		
#		print("\nname =                        ", enemy.name)
#		print("global_position =              ", enemy.global_position)
#		print("target =                       ", enemy.target)
#		print("is_touching_wall =             ", enemy.is_touching_wall)
#		print("can_get_new_target_from_col =  ", enemy.can_get_new_target_from_col)
#		print("angle_to_target =              ", enemy.angle_to_target)
#		print("is_approaching_target =        ", enemy.is_approaching_target)
#		print("angle_to_target_is_expanding = ", enemy.angle_to_target_is_expanding)
		
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




