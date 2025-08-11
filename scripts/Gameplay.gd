
extends Node

onready var main = get_node('/root/Main')
onready var util = get_node('/root/Main/Utilities')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')

onready var drop = preload('res://scenes/Drop.tscn')
onready var mineral_01_texture = preload('res://sprites/tiles/mineral_01.png')
onready var mineral_02_texture = preload('res://sprites/tiles/mineral_02.png')
onready var mineral_03_texture = preload('res://sprites/tiles/mineral_03.png')
onready var enemy_01_texture = preload('res://sprites/enemy_01_drop.png')
onready var enemy_02_a_texture = preload('res://sprites/enemy_02_a_drop.png')
onready var enemy_02_b_texture = preload('res://sprites/enemy_02_b_drop.png')
onready var enemy_02_c_texture = preload('res://sprites/enemy_02_c_drop.png')
onready var enemy_03_texture = preload('res://sprites/enemy_03_drop.png')

onready var DROP_TEXTURE_MAP = {
	'mineral_01': mineral_01_texture,
	'mineral_02': mineral_02_texture,
	'mineral_03': mineral_03_texture,
	'enemy_01': enemy_01_texture,
	'enemy_02_a': enemy_02_a_texture,
	'enemy_02_b': enemy_02_b_texture,
	'enemy_02_c': enemy_02_c_texture,
	'enemy_03': enemy_03_texture,
}

var TILE_MAP_LOGIC_SCN_REF = 'res://scenes/tiles/TileMapLogic.tscn'
var STRUCTURE_GEN_LOGIC_SCN_REF = 'res://scenes/StructureGenLogic.tscn'
var ENEMY_GEN_LOGIC_SCN_REF = 'res://scenes/EnemyGenLogic.tscn'
var SHIP_SCN_REF = 'res://scenes/Ship.tscn'
var HUD_SCN_REF = 'res://scenes/Hud.tscn'

onready var SEED = util.coalesce([null, ctrl.gameplay_seed])
#onready var SEED = util.coalesce([util.rng.randi(), ctrl.gameplay_seed])

var tile_map_logic = null
var tile_map = null
var structure_gen_logic = null
var enemy_gen_logic = null
var ship = null
var camera = null
var hud = null


var cam_noise = OpenSimplexNoise.new()
var cam_shake_noise_x = 0
var cam_shake_trauma = 0.0
var CAM_SHAKE_SPEED = 5  # 1 - 10
var CAM_SHAKE_DECAY = 0.4
var CAM_SHAKE_OFFSET_MOD = 200
var CAM_SHAKE_TRAUMA_MOD = 2.2
var CAM_SHAKE_MAX_OFFSET = 10

onready var mini_map_test = util.coalesce([null, ctrl.gameplay_mini_map_test])

onready var SHIP_START_POS_X = util.coalesce([null, ctrl.gameplay_ship_start_pos_x])
onready var SHIP_START_POS_Y = util.coalesce([null, ctrl.gameplay_ship_start_pos_y])

onready var frame_count = 0


####################################################################################################


func _ready():
	
	print("SEED = ", SEED)
	util.rng.seed = SEED
	
	"""
	level generation order:
		addTileMap()
		addStructures()
		addShip()
		addEnemies()
		AddCamera()
		AddHud()
	"""
	
	addTileMap()
	
#	addStructures()
	
	addShip()
	
	addEnemies()
	
	addCamera()
	
	addHud()
	
	$InteractiveTerrain/MothershipLandingPlatform.ship = ship
	$InteractiveTerrain/MothershipLandingPlatform.hud = hud
	
	if mini_map_test:
		remove_child(hud)
		remove_child(ship)
		remove_child(get_node('Enemies'))
		remove_child(tile_map)
		remove_child(get_node('DestructTileMap'))
		remove_child(get_node('MineralTileMap'))
	else:
		remove_child(get_node('MiniTileMap'))
	
#	hud.setRectsXPosXSizeForSomeGodForesakenReason()
	
	setShipControlType('classic_asteroids')
#	setShipControlType('shuffle_board')
	
#	ship.setControlType('shuffle_board')


func _process(delta):
	
	frame_count += 1
	
	if cam_shake_trauma:
		cam_shake_trauma = max(cam_shake_trauma - (CAM_SHAKE_DECAY * delta), 0)
		shakeCam()


####################################################################################################
""" _ready FUNCS """


func addTileMap():
	tile_map_logic = load(TILE_MAP_LOGIC_SCN_REF).instance()
	tile_map_logic.noise.seed = SEED
	add_child(tile_map_logic)
	tile_map = get_node('TileMap')



#func addStructures():
#
#	structure_gen_logic = load(STRUCTURE_GEN_LOGIC_SCN_REF).instance()
#	add_child(structure_gen_logic)
#
#	structure_gen_logic.terraformForMotherShip()
#
#	tile_map_logic.readyAfterNoiseAndTileCodes()
#
##	structure_gen_logic.genMotherShip()
	





func addEnemies():
	enemy_gen_logic = load(ENEMY_GEN_LOGIC_SCN_REF).instance()
	add_child(enemy_gen_logic)
	enemy_gen_logic.genEnemy01s()
	enemy_gen_logic.genEnemy02s()
	enemy_gen_logic.genEnemy03s()


func addShip():
	ship = load(SHIP_SCN_REF).instance()
	add_child(ship)
	ship.global_position = Vector2(SHIP_START_POS_X, SHIP_START_POS_Y)


func addCamera():
	# set noise attributes
	cam_noise.seed = SEED
	cam_noise.period = CAM_SHAKE_SPEED
	# init camera
	camera = Camera2D.new()
	camera.current = true
	# set camera limits
	var map_limits = tile_map.get_used_rect()
	var map_cellsize = tile_map.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y
	# add camera
	ship.add_child(camera)


func addHud():
	hud = load(HUD_SCN_REF).instance()
	add_child(hud)


func hudAlert(_msg:String, _font_size:int=14) -> void:
	"""
	i put this hud.alert() call in gameplay because the Hud is generated/loaded after many of the other
	systems.  so it can be annoying having to manually detect the Hud Node in every new object or system
	that is created, so i am going to put the Hud externally called functions here, where Hud is already
	manually detected and almost everything is a child of Gameplay
	"""
	hud.alert(_msg, _font_size)


func hudLandingSequenceContainerUp() -> void:
	""" same note as hudAlert() ^ """
	hud.landingSequenceContainerUp()


func hudLandingSequenceContainerDown() -> void:
	""" same note as hudAlert() ^ """
	hud.landingSequenceContainerDown()


####################################################################################################
""" _process FUNCS """


func shakeCam():
	var amount = pow(cam_shake_trauma, CAM_SHAKE_TRAUMA_MOD)
	cam_shake_noise_x += 1
	camera.offset.x = clamp(
		CAM_SHAKE_OFFSET_MOD * amount * cam_noise.get_noise_1d(cam_shake_noise_x),
		-CAM_SHAKE_MAX_OFFSET, CAM_SHAKE_OFFSET_MOD
	)
	camera.offset.y = clamp(
		CAM_SHAKE_OFFSET_MOD * amount * cam_noise.get_noise_1d(cam_shake_noise_x + 1_000),
		-CAM_SHAKE_MAX_OFFSET, CAM_SHAKE_OFFSET_MOD
	)


####################################################################################################


func initDrop(drop_type, drop_value, pos):
	var new_drop = drop.instance()
	new_drop.get_node('Sprite').texture = DROP_TEXTURE_MAP[drop_type]
	new_drop.DROP_TYPE = drop_type
	new_drop.DROP_VALUE = drop_value
	new_drop.global_position = pos
	$Drops.add_child(new_drop)


func dropCollected(drop_type, drop_value):
	var drop_is_new = null
	if not drop_type in data.drops_collected.keys():
		data.drops_collected[drop_type] = {'count': 1, 'value': drop_value}
		drop_is_new = true
	else:
		data.drops_collected[drop_type]['count'] += 1
		data.drops_collected[drop_type]['value'] += drop_value
		drop_is_new = false
	hud.dropCollected(drop_is_new, drop_type)


func getTerrainColDataPack(ship_obj, col_state, col_i) -> Dictionary:
	var data_pack = {}
	data_pack['col_pos'] = col_state.get_contact_local_position(col_i)
	data_pack['speed_damp'] = clamp(
		util.normalize(
			ship_obj.linear_velocity.length(), 0,
			ship_obj.MOVE_MAX_SPEED * ship_obj.COL_DMG_SPEED_MODIFIER, 0, 1
		),
		0, 1
	)
	data_pack['col_angle'] = 90 - abs(rad2deg(
		col_state.get_contact_local_normal(col_i).angle_to(ship_obj.linear_velocity)
	))
	data_pack['col_angle_damp'] = util.normalize(data_pack['col_angle'], 0, 90, 0, 1)
	data_pack['prev_frame_dir'] = ship_obj.prev_frame_dir
	return data_pack


func setTerrainColParticlesFromDataPack(data_pack):
	$ShipToTerrainColParticles2D.global_position = data_pack['col_pos']
	$ShipToTerrainColParticles2D.global_rotation_degrees = data_pack['prev_frame_dir'] + 90
	$ShipToTerrainColParticles2D.process_material.spread = data_pack['col_angle']
	$ShipToTerrainColParticles2D.lifetime = 1 * data_pack['speed_damp']
	$ShipToTerrainColParticles2D.restart()


func setEnemyColParticles(_pos):
	$ShipToEnemyColParticles2D.global_position = _pos
	$ShipToEnemyColParticles2D.restart()


func setShipShootBulletParticles(_pos, _rot):
	$ShipShootBulletParticles2D.global_position = _pos
	$ShipShootBulletParticles2D.rotation = _rot
	$ShipShootBulletParticles2D.restart()


func checkForEnemy03ToFloating(_tile_destroyed:String) -> void:
	for enemy in $Enemies.get_children():
		if util.nodeIsScene(enemy, 'Enemy03'):
			if enemy.cur_holding_tile == null:  return
			var enemy_cur_holding_tiles = [
				'%s,%s' % [enemy.cur_holding_tile.y, 		enemy.cur_holding_tile.x],		# center
				'%s,%s' % [enemy.cur_holding_tile.y - 1,	enemy.cur_holding_tile.x],		# sides \/
				'%s,%s' % [enemy.cur_holding_tile.y + 1,	enemy.cur_holding_tile.x],
				'%s,%s' % [enemy.cur_holding_tile.y, 		enemy.cur_holding_tile.x - 1],
				'%s,%s' % [enemy.cur_holding_tile.y, 		enemy.cur_holding_tile.x + 1],
				'%s,%s' % [enemy.cur_holding_tile.y - 1,	enemy.cur_holding_tile.x - 1],	# corners \/
				'%s,%s' % [enemy.cur_holding_tile.y - 1,	enemy.cur_holding_tile.x + 1],
				'%s,%s' % [enemy.cur_holding_tile.y + 1,	enemy.cur_holding_tile.x - 1],
				'%s,%s' % [enemy.cur_holding_tile.y + 1,	enemy.cur_holding_tile.x + 1],
			]
			for enemy_cur_holding_tile in enemy_cur_holding_tiles:
				if enemy_cur_holding_tile == _tile_destroyed:
					enemy.setMoveStateToFloating()










func setShipControlType(_type:String) -> void:
	ship.CONTROL_TYPE = _type
	
#	ship.rotation_degrees = 0
#	ship.global_rotation_degrees = 0
	
	match _type:
		'classic_asteroids':
			hud.control_type_texture_rect.texture = hud.control_type_classic_asteroids_texture

		'shuffle_board':
			hud.control_type_texture_rect.texture = hud.control_type_shuffle_board_texture
		_:
			util.throwError("Gameplay.setShipControlTypeTexture(_type) accepts _type='classic_asteroids' or _type='shuffle_board'")









