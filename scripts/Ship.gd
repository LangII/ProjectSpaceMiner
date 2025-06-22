

"""
-------------------
LOW PRIORITY TO DOS
-------------------

2023-08-11

- Improve 'shuffle_board' Body rotation visuals.
	
	- When going from complete stop, lerp rotation animation to replace instantanious rotation.
		- Maybe work out some kind of rotation delay if rotation is too fast.  To handle all fast or
		instantanious rotations.
	
	- Add thrust particles.
		- Add particles for linear thrust and rotation thrust.
		- Maybe should add particles for 'classic_asteroids' also.  Or maybe make particles that
		work with both.
"""


extends RigidBody2D

onready var util = get_node('/root/Main/Utilities')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var hud = null  # assigned in Hud.gd

onready var tile_map_logic = get_node('/root/Main/Gameplay/TileMapLogic')
onready var tile_map = get_node('/root/Main/Gameplay/TileMap')

onready var projectiles = get_node('/root/Main/Gameplay/Projectiles')
onready var bullet_01 = preload('res://scenes/Bullet01.tscn')

onready var MOVE_ACC = util.coalesce([null, ctrl.ship_move_acc])
onready var MOVE_MAX_SPEED = util.coalesce([null, ctrl.ship_move_max_speed])
onready var MOVE_MAX_SPEED_RESISTANCE = util.coalesce([null, ctrl.ship_move_max_speed_resistance])

onready var SPIN_ACC = util.coalesce([null, ctrl.ship_spin_acc])
onready var SPIN_MAX_SPEED = util.coalesce([null, ctrl.ship_spin_max_speed])
onready var SPIN_MAX_SPEED_RESISTANCE = util.coalesce([null, ctrl.ship_spin_max_speed_resistance])

onready var TURRET_COOL_DOWN_WAIT_TIME = util.coalesce([null, ctrl.ship_turret_cool_down_wait_time])

onready var MAX_TERRAIN_COL_DMG = util.coalesce([null, ctrl.ship_max_terrain_col_dmg])
onready var MAX_HEALTH = util.coalesce([null, ctrl.ship_max_health])
onready var COL_DMG_SPEED_MODIFIER = util.coalesce([null, ctrl.ship_col_dmg_speed_modifier])
onready var PHYSICAL_ARMOR = util.coalesce([null, ctrl.ship_physical_armor])

onready var DROP_PICK_UP_RADIUS = util.coalesce([null, ctrl.ship_drop_pick_up_radius])

onready var ENEMY_AREA_COL_STRENGTH_MOD = util.coalesce([null, ctrl.ship_enemy_area_col_strength_mod])

onready var CONTROL_TYPE = util.coalesce([null, ctrl.ship_control_type])

var TERRAIN_COL_WAIT_TIME = 0.1
var can_take_terrain_col_dmg = true

onready var health = MAX_HEALTH

var can_shoot = true

var prev_frame_dir = 0

var STUNNED_DELAY = 0.5
var is_stunned = false





####################################################################################################


func _ready():
	
	$CanShootTimer.wait_time = TURRET_COOL_DOWN_WAIT_TIME
	
	$CanTakeTerrainColDmgTimer.wait_time = TERRAIN_COL_WAIT_TIME
	
	$StunnedTimer.wait_time = STUNNED_DELAY
	
	$DropPickUp/CollisionShape2D.shape.radius = DROP_PICK_UP_RADIUS


func _physics_process(_delta):
	
	$Turret.look_at(get_global_mouse_position())
	$Turret.rotate(deg2rad(90))
	
	if Input.is_action_pressed('left_click') and can_shoot:  shoot()


func _integrate_forces(state):
	
	if state.get_contact_count() >= 1:  loopThroughColContacts(state)
	
	setPrevFrameDir(state)
	
	match CONTROL_TYPE:
		
		'classic_asteroids':
			
			applyMoveAccCA()

			applyMoveMaxSpeed()

			applySpinAcc()

			applySpinDamp()

			applySpinMaxSpeed()
	
		'shuffle_board':
			
			applyMoveAccSB()
			
			applyMoveMaxSpeed()
			
			autoRotate()


####################################################################################################
""" _integrate_forces FUNCS """


func setPrevFrameDir(state):
	prev_frame_dir = rad2deg(state.linear_velocity.angle())
	prev_frame_dir = prev_frame_dir if prev_frame_dir > 0 else 360 + prev_frame_dir


func applyMoveAccCA():
	if Input.is_action_pressed('up') and Input.is_action_pressed('down') and not is_stunned:
		applied_force = Vector2()
		linear_damp = 5
	elif Input.is_action_pressed('up') and not is_stunned:
		applied_force = Vector2(0, -MOVE_ACC).rotated(rotation)
		linear_damp = 0
	elif Input.is_action_pressed('down') and not is_stunned:
		applied_force = -Vector2(0, -MOVE_ACC).rotated(rotation)
		linear_damp = 0
	else:
		applied_force = Vector2()
		linear_damp = 0


func applyMoveMaxSpeed():
	if linear_velocity.length() > MOVE_MAX_SPEED:  applied_force = linear_velocity * -MOVE_MAX_SPEED_RESISTANCE


func applySpinAcc():
	if Input.is_action_pressed('right'):  applied_torque = +SPIN_ACC
	elif Input.is_action_pressed('left'):  applied_torque = -SPIN_ACC
	else:  applied_torque = 0


func applySpinDamp():
	# make sure ship only spins when button is pressed
	if Input.is_action_just_pressed('right') or Input.is_action_just_pressed('left'):  angular_damp = 0
	elif Input.is_action_just_released('right') or Input.is_action_just_released('left'):  angular_damp = 200


func applySpinMaxSpeed():
	if abs(angular_velocity) > SPIN_MAX_SPEED:  applied_torque = angular_velocity * -SPIN_MAX_SPEED_RESISTANCE


func applyMoveAccSB() -> void:
	if is_stunned:  return
	if (
		(Input.is_action_pressed('up') and Input.is_action_pressed('down'))
		or (Input.is_action_pressed('left') and Input.is_action_pressed('right'))
	):
		applied_force = Vector2()
		linear_damp = 5
	elif Input.is_action_pressed('up') and Input.is_action_pressed('left'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(-45))
		linear_damp = 0
	elif Input.is_action_pressed('up') and Input.is_action_pressed('right'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(45))
		linear_damp = 0
	elif Input.is_action_pressed('down') and Input.is_action_pressed('left'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(-135))
		linear_damp = 0
	elif Input.is_action_pressed('down') and Input.is_action_pressed('right'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(135))
		linear_damp = 0
	elif Input.is_action_pressed('up'):
		applied_force = Vector2(0, -MOVE_ACC)
		linear_damp = 0
	elif Input.is_action_pressed('down'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(180))
		linear_damp = 0
	elif Input.is_action_pressed('left'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(-90))
		linear_damp = 0
	elif Input.is_action_pressed('right'):
		applied_force = Vector2(0, -MOVE_ACC).rotated(deg2rad(90))
		linear_damp = 0
	else:
		applied_force = Vector2()
		linear_damp = 0


func autoRotate() -> void:
	$Body.look_at(global_position + Vector2(0, 1).rotated(deg2rad(prev_frame_dir)))


func loopThroughColContacts(state):
	for col_i in state.get_contact_count():
		
		# sometimes when colliding with an object that is deleted within the same frame as the
		# collision, the collider object will return 'null instance'
		if not state.get_contact_collider_object(col_i):  continue
		
		if state.get_contact_collider_object(col_i).name == 'TileMap' and can_take_terrain_col_dmg:
			can_take_terrain_col_dmg = false
			$CanTakeTerrainColDmgTimer.start()
			var col_dp = gameplay.getTerrainColDataPack(self, state, col_i)
			var terrain_col_dmg = getTerrainColDmgFromDataPack(col_dp)
			takeDmg(terrain_col_dmg)
			gameplay.setTerrainColParticlesFromDataPack(col_dp)


func getTerrainColDmgFromDataPack(data_pack) -> float:
	return  MAX_TERRAIN_COL_DMG * data_pack['speed_damp'] * data_pack['col_angle_damp'] * (1.0 - PHYSICAL_ARMOR)


####################################################################################################


func shoot():
	# reset can_shoot
	can_shoot = false
	$CanShootTimer.start()
	# get scope vars
	var bullet = bullet_01.instance()
	var bullet_spawn_pos = $Turret/BulletSpawn.global_position
	var bullet_spawn_rot = $Turret/BulletSpawn.global_rotation
	var bullet_vector = Vector2(1, 0).rotated($Turret.global_rotation - deg2rad(90))
	# call bullet spawn funcs
	projectiles.add_child(bullet)
	bullet.start(bullet_spawn_pos, bullet_vector)
	gameplay.setShipShootBulletParticles(bullet_spawn_pos, bullet_spawn_rot)


func takeDmg(_dmg):
	health -= _dmg
	hud.updateHealthValues(health)
	is_stunned = true
	$StunnedTimer.start()
	gameplay.cam_shake_trauma += 0.2


func handleEnemy02AreaCol(_area) -> void:
	# get relevant vars
	var enemy = _area.get_parent()
	# cancel if recently damaged ship
	if not enemy.can_dmg_ship:  return
	# update vars
	enemy.can_dmg_ship = false
	enemy.get_node('CanDmgShipTimer').start()
	# trigger takeDmgs
	takeDmg(enemy.DMG)
	enemy.takeDmg(enemy.DMG * enemy.DMG_TO_SELF_MOD, _area)
	# handle collision physics
	var col_vector = _area.global_position.direction_to(global_position)
	applied_force = col_vector * ENEMY_AREA_COL_STRENGTH_MOD


####################################################################################################
""" signal FUNCS """


func _on_CanShootTimer_timeout():
	can_shoot = true


func _on_DropPickUp_body_entered(body):
	if body.get_parent().name == 'Drops':
		body.shipSensed()


func _on_CanTakeTerrainColDmgTimer_timeout():
	can_take_terrain_col_dmg = true


func _on_StunnedTimer_timeout():
	is_stunned = false


func _on_ShipBodyColArea2D_area_entered(_area):
	
	var area_is_enemy = _area.get_parent().get_parent().name == 'Enemies'
	if area_is_enemy:
		
		var enemy_type = _area.get_parent().name.left(7)
		match enemy_type:
			
			'Enemy02':
				handleEnemy02AreaCol(_area)































