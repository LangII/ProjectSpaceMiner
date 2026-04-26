


extends CanvasLayer



onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')
onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = gameplay.get_node('Ship')
onready var mothership_landing_platform = gameplay.get_node('InteractiveTerrain/MothershipLandingPlatform')

onready var top_left_viewport_container = find_node('TopLeftViewportContainer')
onready var top_left_port = find_node('HudTopLeftPort')
onready var health_bar_under = find_node('HealthTextureProgUnder')
onready var health_bar_over = find_node('HealthTextureProgOver')
onready var health_bar_under_tween = find_node('HealthTextureProgUnderTween')
onready var health_label = find_node('HealthLabel')
onready var angle_meter_color_rect = find_node('ColorRectAngleMeter*')
onready var angle_meter_signal_color_rect = find_node('ColorRectAngleMeterSignal*')
onready var spin_meter_color_rect = find_node('ColorRectSpinMeter*')
onready var spin_meter_signal_color_rect = find_node('ColorRectSpinMeterSignal*')
onready var velocity_meter_color_rect = find_node('ColorRectVelocityMeter*')
onready var velocity_meter_signal_color_rect = find_node('ColorRectVelocityMeterSignal*')
onready var control_type_texture_rect = find_node('ControlTypeTextureRect*')

onready var drop_display_res = preload('res://scenes/iterables/HudDropDisplay.tscn')
onready var control_type_classic_asteroids_texture = preload('res://sprites/control_type_classic_asteroids.png')
onready var control_type_shuffle_board_texture = preload('res://sprites/control_type_shuffle_board.png')



onready var DROP_DISPLAY_COUNT = util.coalesce([null, ctrl.hud_drop_display_count])
onready var DROP_DISPLAY_POS_DIF = 0

onready var HEALTH_TEXT_FORMAT = '%7.2f'
onready var HEALTH_UNDER_TWEEN_DURATION = util.coalesce([null, ctrl.hud_health_under_tween_duration])

onready var drop_displays = []
onready var drop_display_pos = {}

onready var ALERTS_CONTAINER_UP_Y = 472
onready var ALERTS_CONTAINER_DOWN_Y = 506

onready var ALERT_DOWN_TIMER_WAIT_TIME = 2.0

onready var alerts_container_a = $AlertsContainerBoarderA
onready var alerts_label_a = $AlertsContainerBoarderA/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/AlertsLabelA
onready var alerts_container_b = $AlertsContainerBoarderB
onready var alerts_label_b = $AlertsContainerBoarderB/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/AlertsLabelB
onready var current_front_alerts = 'A'  # 'A' or 'B'

onready var landing_sequence_is_up = false

onready var ls_mothership_to_ship_angle = 0
onready var ls_ship_spin_angle = 0
onready var ls_ship_vel = 0
onready var ls_mothership_to_ship_angle_is_green = false
onready var ls_ship_spin_angle_is_green = false
onready var ls_ship_vel_is_green = false



####################################################################################################



func _ready():
	
	ship.hud = self
	
	setDropDisplayPosDif()
	
	setTopLeftViewportHeights()
	
	setDropDisplaysInTopLeftPort()
	
	setHealthValues()
	
	setAlertsContainerPos()
	
	$AlertDownTimerA.wait_time = ALERT_DOWN_TIMER_WAIT_TIME
	$AlertDownTimerB.wait_time = ALERT_DOWN_TIMER_WAIT_TIME
	
	pauseContainerUp()
	
	pauseFadeDown()



func _process(_delta):
	
	if landing_sequence_is_up:  updateLandingSequence()



func _input(_event):
	
	if _event.is_action_pressed('esc'):
		
		if get_tree().paused:
			get_tree().paused = false
			pauseContainerUp()
			pauseFadeDown()
		
		else:
			get_tree().paused = true
			pauseContainerDown()
			pauseFadeUp()



####################################################################################################
""" _ready FUNCS """



func setDropDisplayPosDif():
	var temp_drop_display = drop_display_res.instance()
	DROP_DISPLAY_POS_DIF = temp_drop_display.rect_size.y
	temp_drop_display.queue_free()



func setTopLeftViewportHeights():
	var viewport_height = DROP_DISPLAY_COUNT * DROP_DISPLAY_POS_DIF
	$TopLeftContainerBoarder.rect_size.y = viewport_height + 9
	top_left_viewport_container.rect_size.y = viewport_height
	top_left_viewport_container.get_node('Viewport').size.y = viewport_height



func setDropDisplaysInTopLeftPort():
	for i in (DROP_DISPLAY_COUNT + 1):
		i += 1
		var new_drop_display = drop_display_res.instance()
		new_drop_display.name += str(i)
		top_left_port.add_child(new_drop_display)
		new_drop_display.clearDisplay()
		new_drop_display.rect_position = Vector2(0, DROP_DISPLAY_POS_DIF * (i - 1))
		drop_displays += [new_drop_display]



func setHealthValues():
	health_bar_under.max_value = ship.health
	health_bar_under.value = ship.health
	health_bar_over.max_value = ship.health
	health_bar_over.value = ship.health
	health_label.text = HEALTH_TEXT_FORMAT % [ship.health]



####################################################################################################
""" Top Left FUNCS """



func dropCollected(new, type):
	var drop_texture = gameplay.DROP_TEXTURE_MAP[type]
	if new:
		drop_displays[-1].loadDisplayFromDataDropsCollected(type)
		drop_displays[-1].setAndStartPosTween(0)
		moveDropDisplayFromBackToFront()
		moveAllDropDisplaysDown(DROP_DISPLAY_COUNT)
	else:
		var drop_i = getDropI(drop_texture)
		if drop_i == 0:
			drop_displays[drop_i].loadDisplayFromDataDropsCollected(type)
		elif drop_i:
			drop_displays[drop_i].loadDisplayFromDataDropsCollected(type)
			drop_displays[drop_i].setAndStartPosTween(0)
			moveDropDisplayFromMiddleToFront(drop_i)
			moveAllDropDisplaysDown(drop_i)
		else:
			drop_displays[-1].loadDisplayFromDataDropsCollected(type)
			drop_displays[-1].setAndStartPosTween(0)
			moveDropDisplayFromBackToFront()
			moveAllDropDisplaysDown(DROP_DISPLAY_COUNT)



func getDropI(drop_texture):
	var drop_i = null
	for i in range(len(drop_displays)):
		if drop_displays[i].drop_texture.texture == drop_texture:
			drop_i = i
			break
	return drop_i



func moveDropDisplayFromBackToFront():
	drop_displays.push_front(drop_displays.pop_back())



func moveDropDisplayFromMiddleToFront(middle_i):
	var holder = drop_displays[middle_i]
	drop_displays.remove(middle_i)
	drop_displays.push_front(holder)



func moveAllDropDisplaysDown(to_i):
	for i in range(1, to_i + 1):
		drop_displays[i].setAndStartPosTween(i * DROP_DISPLAY_POS_DIF)



####################################################################################################
""" Bottom FUNCS """



func updateHealthValues(value):
	health_label.text = HEALTH_TEXT_FORMAT % [value]
	health_bar_over.value = value
	health_bar_under_tween.interpolate_property(
		health_bar_under, 'value', null, value, HEALTH_UNDER_TWEEN_DURATION, 0, 2
	)
	health_bar_under_tween.start()



####################################################################################################
""" Alerts FUNCS """



func setAlertsContainerPos() -> void:
	$AlertsContainerBoarderA.margin_top = -34
	$AlertsContainerBoarderA.margin_bottom = 0
	$AlertsContainerBoarderB.margin_top = -34
	$AlertsContainerBoarderB.margin_bottom = 0
	$LandingSequenceContainerBoarder.margin_top = -34
	$LandingSequenceContainerBoarder.margin_bottom = 0



func alert(_msg:String, _font_size:int=14) -> void:
	
	var actual_current_front_alerts = null
	var cur_alerts_container = null
	var cur_alerts_label = null
	var cur_alerts_timer = null
	var cur_alerts_margin_top_tween_up = null
	var cur_alerts_margin_bottom_tween_up = null
	
	match current_front_alerts:
		'A':
			actual_current_front_alerts = current_front_alerts
			cur_alerts_container = alerts_container_a
			cur_alerts_label = alerts_label_a
			cur_alerts_timer = $AlertDownTimerA
			cur_alerts_margin_top_tween_up = $AlertsContainerAMarginTopTweenUp
			cur_alerts_margin_bottom_tween_up = $AlertsContainerAMarginBottomTweenUp
			current_front_alerts = 'B'
		'B':
			actual_current_front_alerts = current_front_alerts
			cur_alerts_container = alerts_container_b
			cur_alerts_label = alerts_label_b
			cur_alerts_timer = $AlertDownTimerB
			cur_alerts_margin_top_tween_up = $AlertsContainerBMarginTopTweenUp
			cur_alerts_margin_bottom_tween_up = $AlertsContainerBMarginBottomTweenUp
			current_front_alerts = 'A'
	
	# this line is to ensure the newer container is drawn on top of the older container
	move_child(cur_alerts_container, 3)
	
	var alerts_label = cur_alerts_label
	alerts_label.text = _msg
	
	# handle fonting
	var new_font = DynamicFont.new()
	new_font.font_data = load("res://resources/Aquarius-RegularMono.ttf") # Load the font file
	new_font.size = _font_size # Set the font size
	alerts_label.add_font_override("font", new_font)
	
	alertContainerUp(cur_alerts_margin_top_tween_up, cur_alerts_margin_bottom_tween_up, cur_alerts_container)
	cur_alerts_timer.start()



func alertContainerUp(_cur_alerts_margin_top_tween_up, _cur_alerts_margin_bottom_tween_up, _cur_alerts_container) -> void:
	_cur_alerts_margin_top_tween_up.interpolate_property(
		_cur_alerts_container,
		'margin_top',
		null,
		-68,
		0.18,
		0,
		0
	)
	_cur_alerts_margin_bottom_tween_up.interpolate_property(
		_cur_alerts_container,
		'margin_bottom',
		null,
		-34,
		0.18,
		0,
		0
	)
	_cur_alerts_margin_top_tween_up.start()
	_cur_alerts_margin_bottom_tween_up.start()



func alertContainerADown() -> void:
	$AlertsContainerAMarginTopTweenDown.interpolate_property(
		$AlertsContainerBoarderA,
		'margin_top',
		null,
		-34,
		0.18,
		0,
		0
	)
	$AlertsContainerAMarginBottomTweenDown.interpolate_property(
		$AlertsContainerBoarderA,
		'margin_bottom',
		null,
		0,
		0.18,
		0,
		0
	)
	$AlertsContainerAMarginTopTweenDown.start()
	$AlertsContainerAMarginBottomTweenDown.start()



func alertContainerBDown() -> void:
	$AlertsContainerBMarginTopTweenDown.interpolate_property(
		$AlertsContainerBoarderB,
		'margin_top',
		null,
		-34,
		0.18,
		0,
		0
	)
	$AlertsContainerBMarginBottomTweenDown.interpolate_property(
		$AlertsContainerBoarderB,
		'margin_bottom',
		null,
		0,
		0.18,
		0,
		0
	)
	$AlertsContainerBMarginTopTweenDown.start()
	$AlertsContainerBMarginBottomTweenDown.start()



func _on_AlertDownTimerA_timeout():
	alertContainerADown()



func _on_AlertDownTimerB_timeout():
	alertContainerBDown()



####################################################################################################
""" Landing Sequence FUNCS """



func landingSequenceContainerUp() -> void:
	landing_sequence_is_up = true
	$LandingSequenceContainerMarginTopTweenUp.interpolate_property(
		$LandingSequenceContainerBoarder,
		'margin_top',
		null,
		-68,
		0.18,
		0,
		0
	)
	$LandingSequenceContainerMarginBottomTweenUp.interpolate_property(
		$LandingSequenceContainerBoarder,
		'margin_bottom',
		null,
		-34,
		0.18,
		0,
		0
	)
	$LandingSequenceContainerMarginTopTweenUp.start()
	$LandingSequenceContainerMarginBottomTweenUp.start()



func landingSequenceContainerDown() -> void:
	landing_sequence_is_up = false
	$LandingSequenceContainerMarginTopTweenDown.interpolate_property(
		$LandingSequenceContainerBoarder,
		'margin_top',
		null,
		-34,
		0.18,
		0,
		0
	)
	$LandingSequenceContainerMarginBottomTweenDown.interpolate_property(
		$LandingSequenceContainerBoarder,
		'margin_bottom',
		null,
		0,
		0.18,
		0,
		0
	)
	$LandingSequenceContainerMarginTopTweenDown.start()
	$LandingSequenceContainerMarginBottomTweenDown.start()



func updateLandingSequence() -> void:
	
	""" Getting & Setting:  Mothership To Ship Angle """
	var platform_pos = mothership_landing_platform.get_node('LandingSequenceArea2D').global_position
	var angle_to = util.convAngleTo360Range2(rad2deg(platform_pos.angle_to_point(ship.global_position)))
	angle_meter_color_rect.rect_rotation = angle_to - 90
	if angle_to >= 70 and angle_to <= 110:
		ls_mothership_to_ship_angle_is_green = true
		angle_meter_signal_color_rect.color = Color(0, 1, 0, 1)
		angle_meter_color_rect.color = Color(0, 1, 0, 1)
	else:
		ls_mothership_to_ship_angle_is_green = false
		angle_meter_signal_color_rect.color = Color(1, 0, 0, 1)
		angle_meter_color_rect.color = Color(1, 1, 1, 1)
	
	""" Getting & Setting:  Ship Spin Angle """
	var spin_to = null
	if ship.CONTROL_TYPE == 'classic_asteroids':
		spin_to = util.convAngleTo360Range2(ship.rotation_degrees)
	elif ship.CONTROL_TYPE == 'shuffle_board':
		spin_to = util.convAngleTo360Range2(ship.get_node('Body').rotation_degrees)
	else:
		util.throwError('what are you thinking, David, go to bed')
	spin_meter_color_rect.rect_rotation = spin_to
	if (
		(spin_to >= 330 and spin_to <= 360)
		or (spin_to >= 0 and spin_to <= 30)
	):
		ls_ship_spin_angle_is_green = true
		spin_meter_signal_color_rect.color = Color(0, 1, 0, 1)
		spin_meter_color_rect.color = Color(0, 1, 0, 1)
	else:
		ls_ship_spin_angle_is_green = false
		spin_meter_signal_color_rect.color = Color(1, 0, 0, 1)
		spin_meter_color_rect.color = Color(1, 1, 1, 1)
	
	""" Getting & Setting:  Ship Velocity """
	var ship_velocity = ship.linear_velocity.length()
	var pos_base = 12
	var meter_pos = util.normalize(clamp(ship_velocity, 0, 100.0), 0, 100, 0, 40)
	velocity_meter_color_rect.rect_position.x = pos_base + meter_pos
	if meter_pos <= 15:
		ls_ship_vel_is_green = true
		velocity_meter_signal_color_rect.color = Color(0, 1, 0, 1)
		velocity_meter_color_rect.color = Color(0, 1, 0, 1)
	else:
		ls_ship_vel_is_green = false
		velocity_meter_signal_color_rect.color = Color(1, 0, 0, 1)
		velocity_meter_color_rect.color = Color(1, 1, 1, 1)



####################################################################################################
""" pause FUNCS """



func pauseContainerUp() -> void:
	$PauseContainerMarginTopTweenUp.interpolate_property(
		$PauseContainerBoarder,
		'margin_top',
		null,
		-550,
		0.18,
		0,
		0
	)
	$PauseContainerMarginBottomTweenUp.interpolate_property(
		$PauseContainerBoarder,
		'margin_bottom',
		null,
		-300,
		0.18,
		0,
		0
	)
	$PauseContainerMarginTopTweenUp.start()
	$PauseContainerMarginBottomTweenUp.start()


func pauseContainerDown() -> void:
	$PauseContainerMarginTopTweenDown.interpolate_property(
		$PauseContainerBoarder,
		'margin_top',
		null,
		-125,
		0.18,
		0,
		0
	)
	$PauseContainerMarginBottomTweenDown.interpolate_property(
		$PauseContainerBoarder,
		'margin_bottom',
		null,
		125,
		0.18,
		0,
		0
	)
	$PauseContainerMarginTopTweenDown.start()
	$PauseContainerMarginBottomTweenDown.start()


func pauseFadeUp() -> void:
	$PauseFadeTweenUp.interpolate_property(
		$PauseFadeColorRect,
		'color:a',
		null,
		0.6,
		0.18,
		0,
		0
	)
	$PauseFadeTweenUp.start()


func pauseFadeDown() -> void:
	$PauseFadeTweenDown.interpolate_property(
		$PauseFadeColorRect,
		'color:a',
		null,
		0,
		0.18,
		0,
		0
	)
	$PauseFadeTweenDown.start()


















