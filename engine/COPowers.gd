extends Node

const power_up = preload("res://assets/gui/power_up.png")

func _ready() -> void:
	var _err = signals.connect("power_start", self, "_on_power_start")
	_err = signals.connect("super_start", self, "_on_super_start")
	_err = signals.connect("turn_started", self, "_on_turn_started")

func _on_power_start(team: Team) -> void:
	if !team.is_power_active and !team.is_super_active:
		team.is_power_active = true
		for unit in team.units:
			apply_power(unit, team.co)

func _on_super_start(team: Team) -> void:
	if !team.is_power_active and !team.is_super_active:
		team.is_super_active = true
		for unit in team.units:
			apply_super(unit, team.co)

func _on_turn_started(team: Team) -> void:
	if team.is_power_active:
		team.is_power_active = false
		for unit in team.units:
			remove_power(unit, team.co)
						
	if team.is_super_active:
		team.is_super_active = false
		for unit in team.units:
			remove_super(unit, team.co)

func apply_power(unit: Unit, co: int):
	match co:
		gl.COS.MARK0:
			unit.set_aux_texture(power_up)
			unit.movement += 1
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod += 0.2

func apply_super(unit: Unit, co: int):
	match co:
		gl.COS.MARK0:
			unit.set_aux_texture(power_up)
			unit.movement += 2
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod += 0.2
				unit.w1_dmg_chart = gl.units[gl.UNITS.LIGHT_TANK].w1_dmg_chart
				unit.w1_can_attack = gl.units[gl.UNITS.LIGHT_TANK].w1_can_attack
				unit.w2_dmg_chart = gl.units[gl.UNITS.LIGHT_TANK].w2_dmg_chart
				unit.w2_can_attack = gl.units[gl.UNITS.LIGHT_TANK].w2_can_attack

func remove_power(unit: Unit, co: int):
	match co:
		gl.COS.MARK0:
			unit.set_aux_texture(null)
			unit.movement -= 1
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod -= 0.2

func remove_super(unit: Unit, co: int):
	match co:
		gl.COS.MARK0:
			unit.set_aux_texture(null)
			unit.movement -= 2
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod -= 0.2
				unit.w1_dmg_chart = gl.units[gl.UNITS.RECON].w1_dmg_chart
				unit.w1_can_attack = gl.units[gl.UNITS.RECON].w1_can_attack
				unit.w2_dmg_chart = gl.units[gl.UNITS.RECON].w2_dmg_chart
				unit.w2_can_attack = gl.units[gl.UNITS.RECON].w2_can_attack
	
