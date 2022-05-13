
extends Node

func normalize(value, min_from, max_from, min_to, max_to):
    value = float(value)
    min_from = float(min_from)
    max_from = float(max_from)
    min_to = float(min_to)
    max_to = float(max_to)
    return (((value - min_from) / (max_from - min_from)) * (max_to - min_to)) + min_to
