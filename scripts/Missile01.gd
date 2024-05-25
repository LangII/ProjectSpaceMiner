

extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var data = get_node('/root/Main/Data')
onready var tile_map = gameplay.get_node('TileMap')
onready var tile_map_logic = get_node('/root/Main/Gameplay/TileMapLogic')

var SPEED = 50.0
var ROT_SPEED = 0.025
var NO_ROT_TARGET_DEG = 30.0

var current_dir = 0.0
var dir_to_ship = 0.0
var current_n_ship_dif = 0.0
var rot_dir = +1  # +1 or -1
var rot_vector = Vector2(-SPEED, 0.0)

onready var BLAST_MAP = [
	{'node_name': 'BlastArea2D01', 'dist': 50.0, 'dmg': 20.0},
#	{'node_name': 'BlastArea2D01', 'dist': 500.0, 'dmg': 20.0},
	{'node_name': 'BlastArea2D02', 'dist': 10.0, 'dmg': 100.0},
]

# BlastParticles2D00 is for even particle displacement through out blast area
onready var BLAST_PARTICLES_00_MAP = {
	'amount': 20, 'explosiveness': 0.5, 'initial_velocity': 100, 'linear_accel': -100
}

# to get accurate values, i manually set BlastArea2D to the desired 'dist' / radius.  then went into
# BlastParticles2D and played with these settings to find what values have the particles dieing at
# just the right distance
onready var BLAST_PARTICLES_MAP = [
	{'node_name': 'BlastParticles2D01', 'amount': 80, 'initial_velocity': 100, 'linear_accel': -100},
	{'node_name': 'BlastParticles2D02', 'amount': 40, 'initial_velocity': 30, 'linear_accel': -40},
]

var col = null
var has_collided = false

var SHIP_COL_IMPULSE_MOD = 20.0

var DESTROY_DROP_CHANCE = 20.0


####################################################################################################


func _ready():
	
	loadBlastAreaNodes()
	
	loadBlastParticlesNodes()


func _process(_delta:float):
	
	if not col:
		
		col = move_and_collide(rot_vector * _delta, false)
	
		updateRotVars()
		
		_rotate()
	
	elif col and not has_collided:
		
		takeDmg()
	


####################################################################################################


func loadBlastAreaNodes() -> void:
	$BlastArea2D01/CollisionShape2D.shape.radius = BLAST_MAP[0]['dist']
	for map in BLAST_MAP.slice(1, BLAST_MAP.size()):
		var area_node = $BlastArea2D01.duplicate()
		area_node.name = map['node_name']
		add_child(area_node)
		var new_col_node = get_node('%s/CollisionShape2D' % map['node_name'])
		new_col_node.shape = new_col_node.shape.duplicate()  # fix for godot bug
		new_col_node.shape.radius = map['dist']


func loadBlastParticlesNodes() -> void:
	$BlastParticles2D00.amount = BLAST_PARTICLES_00_MAP['amount']
	$BlastParticles2D00.explosiveness = BLAST_PARTICLES_00_MAP['explosiveness']
	$BlastParticles2D00.process_material.initial_velocity = BLAST_PARTICLES_00_MAP['initial_velocity']
	$BlastParticles2D00.process_material.linear_accel = BLAST_PARTICLES_00_MAP['linear_accel']
	$BlastParticles2D01.amount = BLAST_PARTICLES_MAP[0]['amount']
	$BlastParticles2D01.process_material.initial_velocity = BLAST_PARTICLES_MAP[0]['initial_velocity']
	$BlastParticles2D01.process_material.linear_accel = BLAST_PARTICLES_MAP[0]['linear_accel']
	for map in BLAST_PARTICLES_MAP.slice(1, BLAST_PARTICLES_MAP.size()):
		var particles_node = $BlastParticles2D01.duplicate()
		particles_node.name = map['node_name']
		add_child(particles_node)
		particles_node.process_material = particles_node.process_material.duplicate()  # fix for godot bug
		particles_node.amount = map['amount']
		particles_node.process_material.initial_velocity = map['initial_velocity']
		particles_node.process_material.linear_accel = map['linear_accel']


####################################################################################################


func updateRotVars() -> void:
	current_dir = util.convAngleTo360Range2(rad2deg(global_rotation))
	dir_to_ship = util.convAngleTo360Range2(rad2deg(global_position.angle_to_point(ship.global_position)))
	current_n_ship_dif = util.anglesDif(current_dir, dir_to_ship)
	rot_dir = current_n_ship_dif / abs(current_n_ship_dif)


func _rotate() -> void:
	# only rotate when not pointing at ship
	if abs(current_n_ship_dif) > NO_ROT_TARGET_DEG:
		rot_vector = rot_vector.rotated(ROT_SPEED * rot_dir)
		rotate(ROT_SPEED * rot_dir)


func printRotVars() -> void:
	print("\ncurrent_dir        = ", current_dir)
	print("dir_to_ship        = ", dir_to_ship)
	print("current_n_ship_dif = ", current_n_ship_dif)
	print("rot_dir            = ", rot_dir)
	print("rot_vector         = ", rot_vector)


func takeDmg(_dmg:float=0.0) -> void:
	
	# ignoring _dmg because Missles react the same for all damage.
	
	if has_collided:  return
	has_collided = true
	
	$Sprite.visible = false
	
	$ExhaustParticles2D.visible = false
	
	$BlastParticles2D00.restart()
	
	$BlastParticles2D01.restart()
	
	for map in BLAST_PARTICLES_MAP.slice(1, BLAST_PARTICLES_MAP.size()):
		
		get_node(map['node_name']).restart()
	
	$QueueFreeDelayTimer.start()
	
	for map in BLAST_MAP:
		
		var col_areas = get_node(map['node_name']).get_overlapping_areas()
		var col_bodies = get_node(map['node_name']).get_overlapping_bodies()
		
		print("\nnode_name = ", map['node_name'])
		print("col_areas = ", col_areas)
		print("col_bodies = ", col_bodies)
		
		for col in col_areas + col_bodies:
			
			# col with SHIP
			if col == ship:
				ship.takeDmg(map['dmg'])
				ship.apply_central_impulse(global_position.direction_to(ship.global_position) * map['dmg'])
			
			# col with PROJECTILES
			if col.get_parent() == gameplay.get_node('Projectiles'):
#				if col != self:
				col.takeDmg(map['dmg'])
			
#			""" STILL NEED TO ACTUALLY TEST WITH ENEMY01 AND ENEMY02 """
			
			# col with ENEMIES
			elif col.get_parent() == gameplay.get_node('Enemies'):
				col.takeDmg(map['dmg'], col)
			# Enemy02 segment handling
			elif util.nodeIsScene(col.get_parent(), 'Enemy02'):
				col.get_parent().takeDmg(map['dmg'], col)
			
			# col with DROPS
			elif col.get_parent() == gameplay.get_node('Drops'):
				
				if util.getRandomBool(DESTROY_DROP_CHANCE):
					col.startExitTweens()
			
		# col with TERRAIN
		"""
		1. get list of "near" tiles
			- with global_position, add and subtract blast radius to get 4 "max" global_position
			corners.  with 4 corners get all tiles within 4 corners
		2. loop through "near" tiles and test if they're within dist from global_position.
		if i have to test each corner of each tile
		"""
		
		var center = tile_map.world_to_map(global_position)
		print("\ncenter          = ", center)
		
		var top_left = tile_map.world_to_map(global_position - Vector2(map['dist'], map['dist']))
		print("top_left        = ", top_left)
		var bottom_right = tile_map.world_to_map(global_position + Vector2(map['dist'], map['dist']))
		print("bottom_right    = ", bottom_right)
		var in_square_tiles = []
		for x in range(top_left.x, bottom_right.x + 1):
			for y in range(top_left.y, bottom_right.y + 1):
				in_square_tiles += [Vector2(x, y)]
		print("in_square_tiles = ", in_square_tiles)
		
		var in_circle_tiles = []
		for tile in in_square_tiles:
			var dist_to_tile = global_position.distance_to(tile_map.map_to_world(tile))
#			print("dist_to_tile = ", dist_to_tile)
			if dist_to_tile < map['dist']:
				in_circle_tiles += [tile]
		print("in_circle_tiles = ", in_circle_tiles)
		
		for tile in in_circle_tiles:
			if data.tiles['%s,%s' % [tile.y, tile.x]]['tile_level'] != 0:
				tile_map_logic.tileTakesDmg(tile, map['dmg'])
		
		"""
		great it works...  but not the greatest...
		
		under the current setup, a tile can get hit multiple times by each blast radius.  this causes
		an order of operations problem.  what i need to do is store tiles and their damage separately,
		then outside the loop go through that stored data so that each tile only gets hit once but with
		a combined value of damage
		"""


####################################################################################################


func start(_pos:Vector2, _rot:float) -> void:
	global_position = _pos
	global_rotation = _rot
	rot_vector = rot_vector.rotated(_rot)
	self.rotate(ROT_SPEED * rot_dir)


####################################################################################################


func _on_ExhaustDelayTimer_timeout():
	$ExhaustParticles2D.emitting = true


func _on_QueueFreeDelayTimer_timeout():
	queue_free()


func _on_MissileBodyColArea2D_area_entered(area):
	print("area.name = ", area.name)
	takeDmg()
