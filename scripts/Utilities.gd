
extends Node

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var ctrl = get_node('/root/Main/Controls')

onready var rng = RandomNumberGenerator.new()


####################################################################################################


func _ready():
	
	rng.randomize()


####################################################################################################


func throwError(error_msg:String) -> void:
	print("\nEXIT ERROR:  " + error_msg)
	get_tree().quit()


func normalize(value, min_from, max_from, min_to, max_to) -> float:
	value = float(value)
	min_from = float(min_from)
	max_from = float(max_from)
	min_to = float(min_to)
	max_to = float(max_to)
	return (((value - min_from) / (max_from - min_from)) * (max_to - min_to)) + min_to


func getRandomInt(_min:int, _max:int) -> int:
	# _min and _max are inclusive
	return rng.randi_range(_min, _max)


func getRandomFloat(_min:float, _max:float) -> float:
	# _min and _max are inclusive
	return rng.randf_range(_min, _max)


func getRandomItemFromArray(_array:Array):
	return _array[getRandomInt(0, len(_array) - 1)]


func getRandomItemFromArrayWithWeights(_array:Array, _weights:Array):
	if len(_array) != len(_weights):
		throwError("when calling Utilities.getRandomItemFromArrayWithWeights(), length of _array must equal length of _weights")
	var sum_weights = 0
	for weight in _weights:
		sum_weights += weight
	if sum_weights != 1.0:
		throwError("when calling Utilities.getRandomItemFromArrayWithWeights(), sum of _weights must equal 1.0")
	var rand_float = getRandomFloat(0.0, 1.0)
	var low = 0.0
	var high = 0.0
	for i in len(_weights):
		var weight = _weights[i]
		low = high
		high += weight
		if rand_float >= low and rand_float <= high:
			return _array[i]


func getRandomBool(_true_perc:float=0.50) -> bool:
	return getRandomItemFromArrayWithWeights([true, false], [_true_perc, 1.0 - _true_perc])


func getSumFromArray(_array:Array) -> float:
	var array_sum = 0.0
	for each in _array:  array_sum += each
	return array_sum


func getAvgFromArray(_array:Array) -> float:
	return getSumFromArray(_array) / _array.size()


func convAngleTo360Range(_angle:float) -> float:
	if _angle >= 0:  return _angle
	else:  return (_angle * -1) + 180


func convAngleTo360Range2(_angle:float) -> float:
	if _angle >= 0:  return _angle
	else:  return (180 - (_angle * -1)) + 180


func convTileMapPosToGlobalPos(tile_map_pos:Vector2, global_pos_type:String='center') -> Vector2:
	var global_pos = data.tiles['%s,%s' % [tile_map_pos.y, tile_map_pos.x]]['global_pos_center']
	global_pos = Vector2(global_pos[0], global_pos[1])
	
	# these vars are based on a hard coded value of the TileMap Tile Width and Height of 20 x 20
	var width_adjust = 10
	var height_adjust = 10
	
	var adjust = {}
	match global_pos_type:
		'top_left':     adjust = {'x': -width_adjust, 'y': -height_adjust}
		'top':          adjust = {'x': 0,             'y': -height_adjust}
		'top_right':    adjust = {'x': +width_adjust, 'y': -height_adjust}
		'center_left':  adjust = {'x': -width_adjust, 'y': 0             }
		'center':       adjust = {'x': 0,             'y': 0             }
		'center_right': adjust = {'x': +width_adjust, 'y': 0             }
		'bottom_left':  adjust = {'x': -width_adjust, 'y': +height_adjust}
		'bottom':       adjust = {'x': 0,             'y': +height_adjust}
		'bottom_right': adjust = {'x': +width_adjust, 'y': +height_adjust}
	global_pos.x += adjust['x']
	global_pos.y += adjust['y']
	return global_pos


func printWithTime(_msg:String) -> void:
	print("%s:%03d|  %s" % [
		Time.get_time_string_from_system(),
		OS.get_system_time_msecs() - OS.get_system_time_secs() * 1_000,
		_msg
	])


func nodeIsScene(_node:Node, _scene:String) -> bool:
	return _node.name.replace('@', '').begins_with(_scene)


func roundToNearestCustom(rounding:float, round_to:Array) -> float:
	var nearest = round_to[0]
	var nearest_dif = abs(rounding - nearest)
	for round_to_each in round_to:
		var dif = abs(rounding - round_to_each)
		if dif < nearest_dif:
			nearest = round_to_each
			nearest_dif = dif
	return nearest


func anglesDif(_angle_1:float, _angle_2:float) -> float:
	return fmod((_angle_2 - _angle_1 + 540), 360) - 180


func coalesce(_array:Array) -> Object:
	for object in _array:
		if object != null:  return object
	return null


func isClockwise(_angle_1: float, _angle_2: float) -> bool:
	"""
	- chatgpt assisted
	- _angle_2 is clockwise from _angle_1
	- this is proven to work for angle degrees of
	N->E->S = 0 -> 180 and N->W->S = 0 -> -180
	"""
	var delta = wrapf(_angle_1 - _angle_2, -180.0, 180.0)
	return not delta > 0














