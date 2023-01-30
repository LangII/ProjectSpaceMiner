

extends KinematicBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var tile_map_logic = get_node('/root/Main/Gameplay/TileMapLogic')
onready var tile_map = get_node('/root/Main/Gameplay/TileMap')

var LIFETIME_WAIT_TIME = 10.0
var COL_PARTICLES_LIFETIME = 1.0
var COLLISION_NORMAL_CLAMP = 0.01
var SPEED = 450
var DMG = 20
#var DMG = 80

var velocity = Vector2()

# Needed, otherwise collisions will bleed over into next few frames causing more damage to object
# collided with.
var has_collided = false

onready var COL_PARTICLE_DISPLACEMENT_MOD = 10


####################################################################################################


func _ready():
	
	$LifeTimeTimer.wait_time = LIFETIME_WAIT_TIME
	$ColParticles2D.lifetime = COL_PARTICLES_LIFETIME
	$ColParticlesLifeTimeTimer.wait_time = COL_PARTICLES_LIFETIME


func _process(delta):
	
	var collision = move_and_collide(velocity * delta)
	
	if collision and not has_collided:
		
		if collision.collider == tile_map:  collidedWithTileMap(collision)
		
		elif collision.collider.get_parent().name == 'Enemies':  collideWithEnemy(collision)


####################################################################################################


func start(pos, dir):
	position = pos
	rotation = dir.angle() + deg2rad(90)
	velocity = dir * SPEED


func collidedWithTileMap(col):
	var mod_normal = col.normal.clamped(COLLISION_NORMAL_CLAMP)
	var tile_pos = tile_map.world_to_map(col.position - mod_normal)
	tile_map_logic.tileTakesDmg(tile_pos, DMG)
	endOfCollision()


func collideWithEnemy(col):
	col.collider.takeDmg(col.collider, DMG)
	endOfCollision()


func endOfCollision():
	has_collided = true
	velocity = Vector2()
	collision_layer = 0
	collision_mask = 0
	$Sprite.visible = false
	$ColParticles2D.restart()
	$ColParticlesLifeTimeTimer.start()


func colParticleDisplacementOnAreaCol() -> void:
	$ColParticles2D.global_position += velocity.rotated(deg2rad(180)).normalized() * COL_PARTICLE_DISPLACEMENT_MOD


####################################################################################################


func _on_ColParticlesLifeTimeTimer_timeout():
	queue_free()


func _on_LifeTimeTimer_timeout():
	queue_free()


func _on_Area2D_area_entered(_area):
	if _area.get_parent().get_parent().name == 'Enemies' and not has_collided:
		_area.get_parent().takeDmg(_area, DMG)
		colParticleDisplacementOnAreaCol()
		endOfCollision()







