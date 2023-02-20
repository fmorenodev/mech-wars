extends Sprite

class_name Building

var team: int setget set_team
var type: int
var available_units : PoolIntArray
var funds: int
var extra # for campaign objectives TODO

func initialize(_type: int, _team: int, _funds: int = 1000, _available_units: PoolIntArray = []) -> void:
	set_team(_team)
	set_type(_type)
	funds = _funds
	if _available_units.size() > 0:
		available_units = _available_units
	else:
		set_available_units()

func set_team(value: int) -> void:
	team = value
	texture = sp.building_sprites[value]

func set_type(value: int) -> void:
	type = value
	frame = type

func set_available_units() -> void:
	match type:
		gl.BUILDINGS.FACTORY:
			available_units = [ gl.UNITS.LIGHT_INFANTRY, gl.UNITS.HEAVY_INFANTRY,
								gl.UNITS.RECON, gl.UNITS.LIGHT_TANK, gl.UNITS.MEDIUM_TANK,
								gl.UNITS.ANTI_AIR, gl.UNITS.ARTILLERY, gl.UNITS.HEAVY_ARTILLERY ]
		gl.BUILDINGS.AIRPORT:
			available_units = [gl.UNITS.DRONE]
		gl.BUILDINGS.PORT:
			available_units = [gl.UNITS.BATTLESHIP]
		_:
			available_units = []

func capture(value: int) -> void:
	set_team(value)
	# extra
