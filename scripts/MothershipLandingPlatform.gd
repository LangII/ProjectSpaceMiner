


extends Node2D



onready var util = get_node('/root/Main/Utilities')
onready var ctrl = get_node('/root/Main/Controls')
onready var gameplay = get_node('/root/Main/Gameplay')
#onready var ship = get_node('/root/Main/Gameplay/Ship')
onready var tilemap = get_node('/root/Main/Gameplay/TileMap')
#onready var hud = get_node('/root/Main/Gameplay/Hud')



# set in gameplay
onready var ship = null
onready var hud = null


onready var LANDING_SEQUENCE_AREA_RADIUS = 200



onready var landing_sequence_is_active = false




func _ready():
	
#	print("\n!!! MothershipLandingPlatform._ready() called !!!\n")
	
#	$Area2D/CollisionShape2D.shape.radius = 200
	
#	this worked in main() test for setting area radius
	
	var new_circle_shape = CircleShape2D.new()
	new_circle_shape.radius = LANDING_SEQUENCE_AREA_RADIUS
	$LandingSequenceArea2D/CollisionShape2D.shape = new_circle_shape





func startLandingSequence() -> void:
	if landing_sequence_is_active:  return
	landing_sequence_is_active = true
	gameplay.hudAlert("Starting Landing Sequence", 13)
	gameplay.hudLandingSequenceContainerUp()
	$LandingPlatformTweenUp.interpolate_property(
		self,
		'position:y',
		null,
		self.position.y - 10,
		0.18,
		0,
		0
	)
	$LandingPlatformTweenUp.start()


func cancelLandingSequence() -> void:
	if not landing_sequence_is_active:  return
	landing_sequence_is_active = false
	gameplay.hudAlert("Canceling Landing Sequence", 13)
	gameplay.hudLandingSequenceContainerDown()
	$LandingPlatformTweenDown.interpolate_property(
		self,
		'position:y',
		null,
		self.position.y + 10,
		0.18,
		0,
		0
	)
	$LandingPlatformTweenDown.start()



func _on_Area2D_body_entered(_body) -> void:
	
	if _body.name != 'Ship':  return
	
	startLandingSequence()


func _on_Area2D_body_exited(_body) -> void:
	
	if _body.name != 'Ship':  return
	
	cancelLandingSequence()


func _on_LandingPlatformArea2D_body_entered(_body) -> void:
	
	if _body.name != 'Ship':  return
	
	if (
		hud.ls_mothership_to_ship_angle_is_green
		and hud.ls_ship_spin_angle_is_green
		and hud.ls_ship_vel_is_green
	):
		hud.alert("LS IS ALL GREEN!!!")
	
	else:
		cancelLandingSequence()
	
	
