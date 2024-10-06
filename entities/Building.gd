extends Sprite

class_name Building

export var team: int setget set_team
export var type: int
var available_units : PoolIntArray
var funds: int
var extra # for campaign objectives TODO

func initialize(_type: int, _team: int, _available_units: PoolIntArray = []) -> void:
	set_team(_team)
	type = _type
	frame = type
	funds = gl.buildings[type].funds
	if _available_units.size() > 0:
		available_units = _available_units
	else:
		set_available_units()

func set_team(value: int) -> void:
	team = value
	texture = sp.building_sprites[value]

func set_available_units() -> void:
	match type:
		gl.BUILDINGS.FACTORY:
			available_units = [ gl.UNITS.LIGHT_INFANTRY, gl.UNITS.HEAVY_INFANTRY,
								gl.UNITS.FLYING_INFANTRY, gl.UNITS.RECON, gl.UNITS.LIGHT_TANK,
								gl.UNITS.MEDIUM_TANK, gl.UNITS.ARTILLERY,
								gl.UNITS.HEAVY_ARTILLERY, gl.UNITS.ARC_TOWER,
								gl.UNITS.ANTI_AIR, gl.UNITS.ROCKET ]
		gl.BUILDINGS.AIRPORT:
			available_units = [gl.UNITS.DRONE, gl.UNITS.ANGEL, gl.UNITS.SKY_FORTRESS]
		gl.BUILDINGS.PORT:
			available_units = [gl.UNITS.BATTLESHIP]
		_:
			available_units = []

func is_production_building() -> bool:
	return (type == gl.BUILDINGS.FACTORY or type == gl.BUILDINGS.AIRPORT or type == gl.BUILDINGS.PORT)

func capture(value: int) -> void:
	set_team(value)
	match type: # TODO: implement building mechanics
		gl.BUILDINGS.RESEARCH:
			pass
		gl.BUILDINGS.POWER_PLANT:
			pass
