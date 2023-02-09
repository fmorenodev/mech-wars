extends PopupMenu

var available_funds: int
var team: int
var building_pos: Vector2

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	signals.emit_signal("unit_added", id, team, building_pos)

func add_option(position: int, id: int) -> void:
	add_icon_item(sp.get_sprite(id), gl.units[id].unit_name, id)
	if available_funds < gl.units[id].cost:
		set_item_disabled(position, true)

func generate_menu(options: PoolIntArray, funds: int, team_color: int, building_position: Vector2) -> void:
	clear()
	available_funds = funds
	team = team_color
	building_pos = building_position
	for i in options.size():
		add_option(i, options[i])

func _on_cancel_pressed() -> void:
	hide()
