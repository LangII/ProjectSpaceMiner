
extends CanvasLayer

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var util = get_node('/root/Main/Utilities')
onready var gameplay = get_node('/root/Main/Gameplay')
onready var ship = gameplay.get_node('Ship')

onready var top_left_viewport_container = find_node('TopLeftViewportContainer')
onready var top_left_port = find_node('HudTopLeftPort')
onready var health_bar_under = find_node('HealthTextureProgUnder')
onready var health_bar_over = find_node('HealthTextureProgOver')
onready var health_bar_under_tween = find_node('HealthTextureProgUnderTween')
onready var health_label = find_node('HealthLabel')
onready var drop_display_res = preload('res://scenes/iterables/HudDropDisplay.tscn')

var DROP_DISPLAY_COUNT = 3
var DROP_DISPLAY_POS_DIF = 0

var HEALTH_TEXT_FORMAT = '%7.2f'
var HEALTH_UNDER_TWEEN_DURATION = 1.0

var drop_displays = []
var drop_display_pos = {}


####################################################################################################


func _ready():
    
    ship.hud = self
    
    setDropDisplayPosDif()
    
    setTopLeftViewportHeights()
    
    setDropDisplaysInTopLeftPort()
    
    setHealthValues()


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
""" top left FUNCS """


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
""" bottom FUNCS """


func updateHealthValues(value):
    health_label.text = HEALTH_TEXT_FORMAT % [value]
    health_bar_over.value = value
    health_bar_under_tween.interpolate_property(
        health_bar_under, 'value', null, value, HEALTH_UNDER_TWEEN_DURATION, 0, 2
    )
    health_bar_under_tween.start()



