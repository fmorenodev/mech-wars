extends PopupMenu

var available_funds: int
var team: Team
var building_pos: Vector2

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	signals.emit_signal("unit_added", id, team.team_id, building_pos)

func add_option(position: int, id: int) -> void:
	var unit = gl.units[id]
	var unit_info: String = ("%s: %d %s, %d %s" % \
		[unit.unit_name, unit.cost, tr("PARTS"), unit.point_cost, tr("UNIT_POINTS")])
	add_icon_item(sp.get_sprite(id), unit_info , id)
	if available_funds < unit.cost or \
	(unit.point_cost + team.unit_points) > team.max_unit_points:
		set_item_disabled(position, true)

func generate_menu(options: PoolIntArray, funds: int, _team: Team, building_position: Vector2) -> void:
	clear()
	available_funds = funds
	team = _team
	building_pos = building_position
	for i in options.size():
		add_option(i, options[i])

func _on_cancel_pressed() -> void:
	hide()
