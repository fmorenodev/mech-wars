extends VBoxContainer

var co: Resource setget set_co

onready var co_name = $HBoxContainer/Name
onready var co_desc = $Desc
onready var icon = $HBoxContainer/Icon
onready var d2d = $DayToDay
onready var power_name = $Powers/Power/Name
onready var super_name = $Powers/Super/Name
onready var power_desc = $Powers/Power/Desc
onready var super_desc = $Powers/Super/Desc

func set_co(value: COData) -> void:
	co_name.text = tr(value.name)
	co_desc.text = tr(value.desc)
	icon.texture = value.texture
	d2d.text = tr(value.d2d)
	power_name.text = tr(value.power_name)
	power_desc.text = tr(value.power_desc)
	super_name.text = tr(value.super_name)
	super_desc.text = tr(value.super_desc)
