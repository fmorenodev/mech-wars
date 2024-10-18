extends Resource
class_name PowerUp

export var id: int
export var text: String
export var amount: float

func apply_power_up(team: Team) -> void:
	match id:
		gl.POWER_UP.ATK_UP:
			for unit in team.units:
				unit.atk_mod += amount
		gl.POWER_UP.DEF_UP:
			for unit in team.units:
				unit.def_mod += amount
		gl.POWER_UP.MOVE_UP:
			for unit in team.units:
				unit.movement += int(amount)
		gl.POWER_UP.FUNDS:
			team.funds += int(amount)

func remove_power_up(team: Team) -> void:
	match id:
		gl.POWER_UP.ATK_UP:
			for unit in team.units:
				unit.atk_mod -= amount
		gl.POWER_UP.DEF_UP:
			for unit in team.units:
				unit.def_mod -= amount
		gl.POWER_UP.MOVE_UP:
			for unit in team.units:
				unit.movement -= int(amount)
		gl.POWER_UP.FUNDS:
			team.funds -= int(amount)
