
extends Node

onready var rng = RandomNumberGenerator.new()


####################################################################################################


func _ready():
    
    rng.randomize()


####################################################################################################


func throwError(error_msg:String) -> void:
    print(error_msg)
    get_tree().quit()


func normalize(value, min_from, max_from, min_to, max_to):
    value = float(value)
    min_from = float(min_from)
    max_from = float(max_from)
    min_to = float(min_to)
    max_to = float(max_to)
    return (((value - min_from) / (max_from - min_from)) * (max_to - min_to)) + min_to


func getRandomInt(_min, _max):
    # _min and _max are inclusive
    return rng.randi_range(_min, _max)


func getRandomFloat(_min, _max):
    # _min and _max are inclusive
    return rng.randf_range(_min, _max)


func getRandomItemFromArray(_array):
    return _array[getRandomInt(0, len(_array) - 1)]



