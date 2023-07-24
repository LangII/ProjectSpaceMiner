
extends RigidBody2D

onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')

onready var LIN_SPEED_MIN = 1
onready var LIN_SPEED_MAX = 20
onready var ROT_SPEED_MIN = 0.5
onready var ROT_SPEED_MAX = 2.5

onready var LINEAR_SPEED = null
onready var DIRECTION = null
onready var ROTATION_SPEED = null

onready var EXIT_TWEEN_DELAY_SECS = 0.25
onready var EXIT_TWEEN_DURATION_SECS = 0.1
onready var EXIT_TWEEN_SCALE = 2.5

var DROP_TYPE = null
var DROP_VALUE = null

onready var vel = Vector2()


####################################################################################################


func _ready():
	
	setExitTweenScale()
	setExitTweenAlpha()
	$ExitTweenDelayTimer.wait_time = EXIT_TWEEN_DELAY_SECS
	$ExitTweenDurationTimer.wait_time = EXIT_TWEEN_DURATION_SECS
	
	LINEAR_SPEED = util.getRandomInt(LIN_SPEED_MIN, LIN_SPEED_MAX)
	DIRECTION = util.getRandomInt(0, 360)
	vel = Vector2(LINEAR_SPEED, 0).rotated(deg2rad(DIRECTION))
	ROTATION_SPEED = util.getRandomFloat(ROT_SPEED_MIN, ROT_SPEED_MAX)
	
	apply_central_impulse(vel)

func _process(_delta):
	
	$Sprite.rotation_degrees += ROTATION_SPEED


####################################################################################################


func setExitTweenScale():
	$ExitTweenScale.interpolate_property(
		$Sprite, 'scale', $Sprite.scale, $Sprite.scale * EXIT_TWEEN_SCALE, EXIT_TWEEN_DURATION_SECS, 0, 2
	)


func setExitTweenAlpha():
	$ExitTweenAlpha.interpolate_property(
		$Sprite, 'modulate', $Sprite.modulate, Color(1, 1, 1, 0), EXIT_TWEEN_DURATION_SECS, 0, 2
	)


func shipSensed():
	$ExitTweenDelayTimer.start()


####################################################################################################


func _on_ExitTweenDelayTimer_timeout():
	gameplay.dropCollected(DROP_TYPE, DROP_VALUE)
	$ExitTweenScale.start()
	$ExitTweenAlpha.start()
	$ExitTweenDurationTimer.start()


func _on_ExitTweenDurationTimer_timeout():
	queue_free()
