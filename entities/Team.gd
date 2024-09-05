extends Resource

class_name Team

var color: int
var units := []
var buildings := []
var funds := 0 setget set_funds
var funds_per_turn := 0
var is_player: bool
var lost_units := 0
var co setget set_co
var is_power_active: bool = false
var is_super_active: bool = false

# new resource implementation
var co_resource: COData

func _init(_color: int, _is_player: bool) -> void:
	color = _color
	is_player = _is_player

func add_unit(unit: Unit) -> void:
	unit.team = color
	units.append(unit)

func add_building(building) -> void:
	buildings.append(building)
	calculate_funds_per_turn()

func calculate_funds_per_turn() -> void:
	funds_per_turn = 0
	for building in buildings:
		funds_per_turn += building.funds
	signals.emit_signal("funds_per_turn_updated", funds_per_turn)

func set_funds(value: int) -> void:
	funds = value
	signals.emit_signal("funds_updated", funds)

func set_co(value: int) -> void:
	co = value
	co_resource = load(gl.co_data[co].co_res)
	for unit in units:
		unit.set_co(co)
