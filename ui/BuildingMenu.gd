extends PopupMenu

var available_funds: int
var team: int
var building_pos: Vector2

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	signals.emit_signal("unit_added", id, team, building_pos)

func add_option(id: int) -> void:
	match id:
		gl.UNITS.LIGHT_INFANTRY:
			add_icon_item(sp.light_inf, gl.units[gl.UNITS.LIGHT_INFANTRY].unit_name, id)
			if available_funds < gl.units[gl.UNITS.LIGHT_INFANTRY].cost:
				set_item_disabled(id, true)
		gl.UNITS.ARTILLERY:
			add_icon_item(sp.artillery, gl.units[gl.UNITS.ARTILLERY].unit_name, id)
			if available_funds < gl.units[gl.UNITS.ARTILLERY].cost:
				set_item_disabled(id, true)

func generate_menu(options: PoolIntArray, funds: int, team_color: int, building_position: Vector2) -> void:
	clear()
	available_funds = funds
	team = team_color
	building_pos = building_position
	for id in options:
		add_option(id)

func _on_cancel_pressed() -> void:
	hide()
