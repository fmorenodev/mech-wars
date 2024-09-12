extends Resource

class_name Team

var team_id: int
var color: Color # TODO: use team color for UIs
var units := []
var buildings := []
var funds := 0 setget set_funds
var funds_per_turn := 0
var is_player: bool
var lost_units := 0
var co setget set_co
var is_power_active: bool = false
var is_power_enabled: bool = false
var is_super_active: bool = false
var is_super_enabled: bool = false
var power_meter_amount: float = 0 setget set_power_meter_amount # same for both super and power
var powers_used := 0

# new resource implementation
var co_resource: COData

func _init(_team_id: int, _is_player: bool) -> void:
	team_id = _team_id
	is_player = _is_player
	match team_id:
		0:
			color = Color.firebrick
		1:
			color = Color.dodgerblue

func add_unit(unit: Unit) -> void:
	unit.team = team_id
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

func set_power_meter_amount(value: float) -> void:
	power_meter_amount = value
	if (value >= co_resource.power_meter_size):
		is_power_enabled = true
	else:
		is_power_enabled = false
	if (value >= co_resource.super_meter_size + co_resource.power_meter_size):
		if co != gl.COS.BOSS:
			is_super_enabled = true
	else:
		is_super_enabled = false
	
	signals.emit_signal("update_meter", self)
