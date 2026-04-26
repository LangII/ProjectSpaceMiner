
"""

ELEVATOR PITCH:
Going for a Gradius-like / Terraria-like shmup.  Using simplex noise procedurally generated levels,
for an Exploratory-like, and Adventure-like, procedurally generated Gradius.



---------------
FINAL MVP TASKS
---------------

- DONE - adjust settings for windows <> mac

- mothership

- menus

	- pause
	
	- level generation / settings
	
	- title

- death / restart-level sequence

order to complete:
	- windows <> mac adjustments
	- mothership
	- pause menu
	- level-generation / settings menu
	- death / level-restart
	- title menu




----------
NEXT TODOS
----------

2025-08-11

pushed commit:
added new core objects (functional, but all dirty code, needs cleaning):
	Fixtures
		Mothership
	InteractiveTerrain
		MothershipLandingPlatform
	Hud
		Alerts
		LandingSequence
		Pause

NEXT TODO is clean this code ^
- files to be cleaned:
	- Ship.gd



- in Gameplay.gd, the _ready() func is doing a lot of lifting inside FinalTileMapLogic.gd - _ready().
which is fine, but that needs to be described/expressed either in naming or comments
	- generally should probably rework Gameplay._ready()

- add logic to allow Mothership to take damage.  maybe add this work to Ship dying / endgame


-----
NOTES
-----

2025-08-29
- How to manage the Ship/Asteroid "Class" System:

	- Each Asteroid will also have a Class level (A, B, C).
		- Seeds (Asteroids) examples = 100-A, 101-B, 123-C, 245-C, 678-A
		- 1 Seed can NOT have MANY Classes.  This is to not disturb the user-experience "Surprise"
		element.  If a Player played 100-A, then later played 100-B, then the levels would be very
		very similar, therefore reducing the "newness" experience of the player.  Considering that
		with the current design there are 10 billion available Seeds, there is no issue with this
		implementation limiting the number of levels.
			- TBD is how to ensure Seeds are not reused.
	
	- Each Asteroid Class will have a different Class Strength Minimum.  Which is a minimum value/score
	that the Player has to achieve to be able to play that Class Level of Asteroids.
	
	- Each Ship or Mothership upgrade will come with a Class Strength value (1, 2, 3).
		- When the Player is Asteroid selecting (level selecting), all of a Player's currently
		equipped Ship Upgrades and Mothership Upgrades Class Strength values will be summed to
		determine what the Player's current Total Class Strength is.
	
	- If the Player's current Total Class Strength is higher than an Asteroid Class Strength Minimum,
	then the Player can play that Class of Asteroids.

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

var gameplay = null



####################################################################################################



func _ready():
	
	
	
	################################################################################################
	""" TESTING """
	
	
	
	
	
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
		
		var data = get_node('/root/Main/Data')
		var k = '%s,%s' % [mouse_pos_tile.y, mouse_pos_tile.x]
		print("mouse tile = ", data.tiles[k])
		print("")
		
		var gameplay = get_node('Gameplay')
		gameplay.hudAlert("This Is An Alert...")

















