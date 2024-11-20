extends Resource
class_name PowerMod

export var id: int
export var text: String
export var amount: float

var source_building: Building

func _init(_id: int, _amount: float):
	var _err = signals.connect("remove_power_mod", self, "_on_remove_mod")
	id = _id
	amount = _amount
	match id:
		gl.POWER_MOD.ATK_MOD:
			text = "ATK_MOD_POP_UP"
		gl.POWER_MOD.DEF_MOD:
			text = "DEF_MOD_POP_UP"
		gl.POWER_MOD.MOVE_MOD:
			text = "MOVE_MOD_POP_UP"
		gl.POWER_MOD.CAP_MOD:
			text = "CAP_MOD_POP_UP"
		gl.POWER_MOD.FUNDS:
			text = "FUNDS_MOD_POP_UP"

func apply_mod(team: Team) -> void:
	match id:
		gl.POWER_MOD.ATK_MOD:
			for unit in team.units:
				unit.atk_mod += amount
		gl.POWER_MOD.DEF_MOD:
			for unit in team.units:
				unit.def_mod += amount
		gl.POWER_MOD.MOVE_MOD:
			for unit in team.units:
				unit.movement += int(amount)
		gl.POWER_MOD.CAP_MOD:
			for unit in team.units:
				if unit.can_capture:
					unit.cap_mod += amount
		gl.POWER_MOD.FUNDS:
			team.funds += int(amount)

func remove_mod(team: Team) -> void:
	match id:
		gl.POWER_MOD.ATK_MOD:
			for unit in team.units:
				unit.atk_mod -= amount
		gl.POWER_MOD.DEF_MOD:
			for unit in team.units:
				unit.def_mod -= amount
		gl.POWER_MOD.MOVE_MOD:
			for unit in team.units:
				unit.movement -= int(amount)
		gl.POWER_MOD.CAP_MOD:
			for unit in team.units:
				if unit.can_capture:
					unit.cap_mod -= amount
		gl.POWER_MOD.FUNDS:
			team.funds -= int(amount)

func _on_remove_mod(team: Team, building: Building) -> void:
	if building == source_building:
		remove_mod(team)
