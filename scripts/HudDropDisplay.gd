
extends PanelContainer

onready var main = get_node('/root/Main')
onready var data = get_node('/root/Main/Data')
onready var gameplay = get_node('/root/Main/Gameplay')

onready var drop_texture = $HBoxContainer/PanelContainer/DropTexture
onready var count_label = $HBoxContainer/CountLabel
onready var value_label = $HBoxContainer/ValueLabel

onready var POS_TWEEN_DURATION_SECS = 0.2


####################################################################################################


func setAndStartPosTween(new_pos):
	$PosTween.interpolate_property(
		self, 'rect_position', null, Vector2(0, new_pos), POS_TWEEN_DURATION_SECS, 0, 2
	)
	$PosTween.start()


func loadDisplayFromDataDropsCollected(drop_type):
	loadDisplay(
		gameplay.DROP_TEXTURE_MAP[drop_type],
		data.drops_collected[drop_type]['count'],
		data.drops_collected[drop_type]['value']
	)


func loadDisplay(texture, count, value):
	self.visible = true
	drop_texture.texture = texture
	count_label.text = str(count)
	value_label.text = str(value)


func clearDisplay():
	loadDisplay(null, '', '')
	self.visible = false




