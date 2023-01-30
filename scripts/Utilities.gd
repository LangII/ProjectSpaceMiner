
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


func convAngleTo360Range(_angle:float) -> float:
	if _angle >= 0:  return _angle
	else:  return (_angle * -1) + 180


func convTileMapPosToGlobalPos(tile_map_pos:Vector2, global_pos_type:String='middle') -> Vector2:
	var global_pos = data.tiles['%s,%s' % [tile_map_pos.y, tile_map_pos.x]]['global_pos_center']
	global_pos = Vector2(global_pos[0], global_pos[1])
	var width_adjust = ctrl.tile_width / 2
	var height_adjust = ctrl.tile_height / 2
	var adjust = {}
	match global_pos_type:
		'top_left':     adjust = {'x': -width_adjust, 'y': -height_adjust}
		'top':          adjust = {'x': 0,             'y': -height_adjust}
		'top_right':    adjust = {'x': +width_adjust, 'y': -height_adjust}
		'center_left':  adjust = {'x': -width_adjust, 'y': 0             }
		'middle':       adjust = {'x': 0,             'y': 0             }
		'center_right': adjust = {'x': +width_adjust, 'y': 0             }
		'bottom_left':  adjust = {'x': -width_adjust, 'y': +height_adjust}
		'bottom':       adjust = {'x': 0,             'y': +height_adjust}
		'bottom_right': adjust = {'x': +width_adjust, 'y': +height_adjust}
	global_pos.x += adjust['x']
	global_pos.y += adjust['y']
	return global_pos

















