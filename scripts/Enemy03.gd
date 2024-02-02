

"""
--------------
BEHAVIOR NOTES
--------------

- MOTION STATES
	- on wall
		- walking
		- turning
			- concave
			- convex
	- floating
	- landing (transition from floating to on wall (transition from on wall to floating is instant))
- ATTACK STATES
	- can shoot (based on cool down)
	- is looking at ship (turret is pointed at ship)
	- is targeting ship (turret is turning towards ship)
	- ship is in range
	- ready
	- 

-----
TODOS
-----

2023-08-20

DONE
- Add nodes and code to allow for rolling 'left'.

DONE
- Add alternate between roll left and roll right behavior.

DONE
- Add rotation to float.

DONE
- Add behavior for 'rolling' -> 'floating' when dependent terrain is destroyed.
	
	DONE
	- cur_dependent_tiles = list of tiles that Enemy03 is currently dependent on
	
	DONE
	- whenever a tile is broken, get all cur_dependent_tiles for all enemy_03s
	
	DONE
	- if the broken tile is in one of those lists, then trigger that enemy_03 to 'floating' state

(
	2024-01-30
	DONE
	test and clean up all previous DONEs
)

- Add damage exchange behavior for when Ship and Enemy03 (body to body) collide.

- Add turret for missiles.

- Use shooting of Ship to add shooting to Enemy03.  Maybe for now just have it shoot Bullet01.

- Upgrade from Bullet01 to Bullet02, a slow moving homing AOE.

- Have ship bullets damage Enemy03.

- Add control to not allow Enemy03 to walk up the sky walls (hashed blocks).

2024-01-31
Under the current state, while it is cool behavior to make it so that the Ship can trigger an
Enemy03 into 'floating' move_state by destroying holding tile(s), it gives the Ship an advantage
over Enemy03.  Part of the defense of Enemy03 is it's rapid back-and-forth movement while wall
crawling.  When in the 'floating' move_state there is no longer that defensive movement.  So, to
counter this I'll make it so that while in 'floating' move_state Enemy03 has an increase in defense.

-----
OTHER
-----

- One problem with the current method of "rolling" is that I don't know how to make the roll speed
adjustable.
"""


extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')

#onready var mineral_tilemap = get_node('/root/Main/Gameplay/MineralTileMap')
#var cur_holding_min_tile = null

var ROT_NODE_MAP = {
	'RotPosA': {
		'next_pos_node':	{'right': 'RotPosD',		'left': 'RotPosB'},
		'col_ray':			{'right': 'ColRayARight',	'left': 'ColRayALeft'}
	},
	'RotPosB': {
		'next_pos_node':	{'right': 'RotPosA',		'left': 'RotPosC'},
		'col_ray':			{'right': 'ColRayBRight',	'left': 'ColRayBLeft'}
	},
	'RotPosC': {
		'next_pos_node':	{'right': 'RotPosB',		'left': 'RotPosD'},
		'col_ray':			{'right': 'ColRayCRight',	'left': 'ColRayCLeft'}
	},
	'RotPosD': {
		'next_pos_node':	{'right': 'RotPosC',		'left': 'RotPosA'},
		'col_ray':			{'right': 'ColRayDRight',	'left': 'ColRayDLeft'}
	}
}

var move_state = ''  # 'floating' or 'rolling'

var cur_rotate_around_node = null
var cur_rotate_around_pos = Vector2()
var cur_roll_dir = ''
var cur_roll_dir_mod = 0
var cur_rotated_enough_ray = null

var FLOATING_LINEAR_SPEED_MIN = 10.0
var FLOATING_LINEAR_SPEED_MAX = 100.0
var FLOATING_ROTATE_SPEED_MIN = 0.01
var FLOATING_ROTATE_SPEED_MAX = 0.2

var ROLLING_CHANGE_DIR_CHANCE_MIN = 0.001  # perc
var ROLLING_CHANGE_DIR_CHANCE_MAX = 0.300  # perc

var ROLLING_MOV_MOD = 0.08
var ROLLING_ROT_MOD = 4.0

var floating_linear_speed = 0.0
var floating_linear_dir = 0.0
var floating_move_vector = Vector2()
var floating_rotate_speed = 0.0
var floating_rotate_dir = ''
var floating_rotate_dir_mod = 0

onready var cur_holding_tile = null


####################################################################################################


func _ready() -> void:
	
	setMoveStateToFloating()
	
	# TEST
	floating_linear_dir = 0.0
	floating_move_vector = Vector2(floating_linear_speed, 0).rotated(deg2rad(floating_linear_dir))


func _process(_delta:float) -> void:
	
	match move_state:
		
		'floating':
			
			rotate(floating_rotate_dir_mod * floating_rotate_speed)
			
			var col = move_and_collide(floating_move_vector * _delta, false)
			
			if col:
				
				if col.collider == tilemap:
					
					setMoveStateToRolling(col.position)
		
		'rolling':
			
			if cur_rotated_enough_ray.is_colliding():
				
				setCurHoldingTile()
				
				if util.getRandomBool(
					util.getRandomFloat(
						ROLLING_CHANGE_DIR_CHANCE_MIN,
						ROLLING_CHANGE_DIR_CHANCE_MAX
					)
				):
					
					changeCurRollDir()
					
					setCurRotatedEnoughRay()
				
				else:
				
					updateColVars()
			
			handleRollingMovement()


####################################################################################################


func setMoveStateToFloating() -> void:
	move_state = 'floating'
	floating_linear_speed = util.getRandomFloat(FLOATING_LINEAR_SPEED_MIN, FLOATING_LINEAR_SPEED_MAX)
	floating_linear_dir = util.getRandomFloat(0.0, 360.0)
	floating_move_vector = Vector2(floating_linear_speed, 0).rotated(deg2rad(floating_linear_dir))
	floating_rotate_speed = util.getRandomFloat(FLOATING_ROTATE_SPEED_MIN, FLOATING_ROTATE_SPEED_MAX)
	floating_rotate_dir = util.getRandomItemFromArray(['left', 'right'])
	floating_rotate_dir_mod = -1 if floating_rotate_dir == 'left' else +1
	set_collision_mask_bit(1, true)
	cur_holding_tile = null


func setMoveStateToRolling(_col_position:Vector2) -> void:
	set_collision_mask_bit(1, false)  # ignore terrain col while walking
	smallRotateAfterTerrainCol(_col_position)
	move_state = 'rolling'
	cur_rotate_around_node = getClosestRotPosNode(_col_position)
	cur_rotate_around_pos = cur_rotate_around_node.global_position
	cur_roll_dir = util.getRandomItemFromArray(['left', 'right'])
	cur_roll_dir_mod = -1 if cur_roll_dir == 'left' else +1
	setCurRotatedEnoughRay()


func setCurRotatedEnoughRay() -> void:
	cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_roll_dir])


func handleRollingMovement() -> void:
	global_position = (
		cur_rotate_around_pos
		+ (global_position - cur_rotate_around_pos).rotated(cur_roll_dir_mod * ROLLING_MOV_MOD)
	)
	rotate(deg2rad(cur_roll_dir_mod * ROLLING_ROT_MOD))


func updateColVars() -> void:
	cur_rotate_around_node = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['next_pos_node'][cur_roll_dir])
	cur_rotate_around_pos = cur_rotate_around_node.global_position
	cur_rotated_enough_ray = get_node(ROT_NODE_MAP[cur_rotate_around_node.name]['col_ray'][cur_roll_dir])


func printColVars() -> void:
	print("\ncur_rotate_around_node = ", cur_rotate_around_node.name)
	print("cur_rotate_around_pos  = ", cur_rotate_around_pos)
	print("cur_roll_dir           = ", cur_roll_dir)
	print("cur_rotated_enough_ray = ", cur_rotated_enough_ray.name)


func smallRotateAfterTerrainCol(_col_pos:Vector2) -> void:
	var closest_rot_pos_node_name = getClosestRotPosNode(_col_pos).name
	var closest_rot_pos_v = global_position - getClosestRotPosNode(_col_pos).global_position
	var col_pos_v = global_position - _col_pos
	var angle_to = closest_rot_pos_v.angle_to(col_pos_v)
	rotate(angle_to)


func getClosestRotPosNode(_pos:Vector2) -> Node:
	var closest_rot_pos_node_ = null
	var rot_pos_nodes = ROT_NODE_MAP.keys()
	var dists = [
		$RotPosA.global_position.distance_to(_pos), $RotPosB.global_position.distance_to(_pos),
		$RotPosC.global_position.distance_to(_pos), $RotPosD.global_position.distance_to(_pos)
	]
	closest_rot_pos_node_ = get_node(rot_pos_nodes[dists.find(dists.min())])
	return closest_rot_pos_node_


func changeCurRollDir() -> void:
	cur_roll_dir = 'left' if cur_roll_dir == 'right' else 'right'
	cur_roll_dir_mod = -1 if cur_roll_dir_mod == +1 else +1


func setCurHoldingTile() -> void:
	cur_holding_tile = tilemap.world_to_map(cur_rotated_enough_ray.get_collision_point())



func takeDmg(_node_took_dmg:Object, _dmg:int) -> void:
	return







































