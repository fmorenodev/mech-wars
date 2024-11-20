extends VBoxContainer

var row = preload("res://ui/TableRow.tscn")
onready var Table = $ScrollContainer/TableContent

var row_n: int
var table_units: Array

func _ready():
	var _err = signals.connect("send_units_to_table", self, "set_data")
	$Header/Unit.text = tr("UNIT_ICON_HEADER")
	$Header/Name.text = tr("UNIT_TYPE_HEADER")
	$Header/HP.text = tr("UNIT_HP_HEADER")
	$Header/Ammo.text = tr("UNIT_AMMO_HEADER")
	$Header/Energy.text = tr("UNIT_ENERGY_HEADER")

func set_data(units: Array) -> void:
	row_n = 0
	for child in Table.get_children():
		Table.remove_child(child)
		child.queue_free()
	table_units = units
	for unit in units:
		set_row(unit)

func set_row(unit: Unit) -> void:
	var row_instance = row.instance()
	row_instance.name = str(row_n)
	row_n += 1
	Table.add_child(row_instance)
	row_instance.connect("row_button_pressed", self, "_on_row_button_pressed")
	
	var instance_path = "ScrollContainer/TableContent/%s/%s"
	get_node(instance_path % [row_instance.name, "/HBoxContainer/TextureButton"]).texture_normal = unit.texture.get_frame('idle', 0)
	get_node(instance_path % [row_instance.name, "/HBoxContainer/TextureButton"]).material = sp.team_materials[unit.team_id]
	get_node(instance_path % [row_instance.name, "/Label"]).text = gl.units[unit.id].unit_name
	get_node(instance_path % [row_instance.name, "/Label2"]).text = str(unit.rounded_health)
	get_node(instance_path % [row_instance.name, "/Label3"]).text = str(unit.ammo) if (unit.ammo != -1) else tr("INFINITE")
	get_node(instance_path % [row_instance.name, "/Label4"]).text = str(unit.energy)

# TODO: fix this (issue #15)
func _on_row_button_pressed(row_name: String) -> void:
	get_parent().hide()
	gl.move_mouse_global(table_units[int(row_name)].position)
