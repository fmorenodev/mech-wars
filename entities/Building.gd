extends Sprite

class_name Building

export var team_id: int setget set_team_id
export var type: int
var allegiance := -1
var available_units: PoolIntArray
var funds: int
var power_mods: Array

func _ready() -> void:
	var _err = signals.connect("change_unlocked_factory_units", self, "set_available_units")

func initialize(_type: int, _team_id: int, unlocked: bool, _available_units: PoolIntArray = []) -> void:
	set_team_id(_team_id)
	type = _type
	# TODO: remove, temp until i make sprites for the other buildings
	if type == gl.BUILDINGS.RESEARCH_2 or type == gl.BUILDINGS.RESEARCH_3:
		frame = gl.BUILDINGS.RESEARCH
	else:
		frame = type
	funds = gl.buildings[type].funds
	if _available_units.size() > 0:
		available_units = _available_units
	else:
		set_available_units(unlocked, team_id)

func set_team_id(value: int) -> void:
	team_id = value
	texture = sp.get_building_sprite(value)

func set_available_units(unlocked: bool, _team_id: int) -> void:
	if team_id == _team_id:
		match type:
			gl.BUILDINGS.FACTORY:
				if unlocked:
					available_units = [ gl.UNITS.LIGHT_INFANTRY, gl.UNITS.HEAVY_INFANTRY,
									gl.UNITS.FLYING_INFANTRY, gl.UNITS.RECON, gl.UNITS.LIGHT_TANK,
									gl.UNITS.MEDIUM_TANK, gl.UNITS.ARTILLERY,
									gl.UNITS.HEAVY_ARTILLERY, gl.UNITS.ARC_TOWER,
									gl.UNITS.ANTI_AIR, gl.UNITS.ROCKET ]
				else:
					available_units = [ gl.UNITS.LIGHT_INFANTRY, gl.UNITS.HEAVY_INFANTRY,
									gl.UNITS.FLYING_INFANTRY, gl.UNITS.RECON]
			gl.BUILDINGS.AIRPORT:
				available_units = [gl.UNITS.DRONE, gl.UNITS.ANGEL, gl.UNITS.SKY_FORTRESS]
			gl.BUILDINGS.PORT:
				available_units = [gl.UNITS.BATTLESHIP]
			_:
				available_units = []

func is_production_building() -> bool:
	return (type == gl.BUILDINGS.FACTORY or type == gl.BUILDINGS.AIRPORT or type == gl.BUILDINGS.PORT)

func capture(capturing_team: Team, last_owner = null) -> void:
	set_team_id(capturing_team.team_id)
	allegiance = capturing_team.allegiance
	match type:
		gl.BUILDINGS.RESEARCH: # unlock vehicle type mechs
			if last_owner:
				last_owner.unlocked_factory_units = false
			capturing_team.unlocked_factory_units = true
		gl.BUILDINGS.POWER_PLANT:
			if last_owner:
				last_owner.max_unit_points -= 10
			capturing_team.max_unit_points += 10
		gl.BUILDINGS.RESEARCH_2: # powerups
			if last_owner:
				signals.emit_signal("remove_power_mod", last_owner, self)
			signals.emit_signal("choose_power_mod", capturing_team, power_mods, self)
		gl.BUILDINGS.RESEARCH_3: # new unit version
			pass

func repair(unit: Unit, team: Team) -> void:
	if can_repair(unit):
		unit.ammo = gl.units[unit.id].ammo
		unit.energy = gl.units[unit.id].energy
		var damage = unit.max_health - unit.health
		if damage > 0:
			var repair_cost = unit.cost * min(0.2, damage / 10)
			if repair_cost <= team.funds:
				unit.health += min(damage, 2)
				team.funds -= repair_cost

func can_repair(unit: Unit) -> bool:
	if gl.buildings[type].repairs.has(unit.move_type) and allegiance == unit.allegiance:
		return true
	return false
