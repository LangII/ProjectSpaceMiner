
extends Node

onready var rng = RandomNumberGenerator.new()


####################################################################################################


func _ready():
    
    rng.randomize()


####################################################################################################


func throwError(error_msg:String) -> void:
    print(error_msg)
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


