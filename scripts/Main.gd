
extends Node

func _ready():
    
    add_child(load('res://scenes/TileMapLogic.tscn').instance())
    
    add_child(load('res://scenes/Ship.tscn').instance())
    
    Input.set_custom_mouse_cursor(load('res://sprites/cursor.png'), 0, Vector2(20, 20))

