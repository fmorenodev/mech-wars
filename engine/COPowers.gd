extends Node

onready var Main = $".."

const power_up = preload("res://assets/gui/power_up.png")

func _ready() -> void:
	var _err = signals.connect("power_start", self, "_on_power_start")
	_err = signals.connect("super_start", self, "_on_super_start")
	_err = signals.connect("turn_started", self, "_on_turn_started")

func _on_power_start(active_team: Team) -> void:
	if !active_team.is_power_active and !active_team.is_super_active\
	and active_team.is_power_enabled:
		
		active_team.is_power_enabled = false
		active_team.is_power_active = true
		active_team.powers_used += 1
		active_team.power_meter_amount = 0
		
		match active_team.co:
			# other team effects
			gl.COS.BOSS:
				for team in Main.teams:
					if team != active_team:
						for unit in team.units:
							unit.max_health -= 1
							unit.health -= 1
			_: # own team effects
				for unit in active_team.units:
					apply_power(unit, active_team.co)

func _on_super_start(active_team: Team) -> void:
	if !active_team.is_power_active and !active_team.is_super_active\
	and active_team.is_super_enabled:
		
		active_team.is_super_enabled = false
		active_team.is_super_active = true
		active_team.powers_used += 1
		active_team.power_meter_amount = 0
		
		match active_team.co:
			# other team effects
			gl.COS.EVIL_MARK0:
				for i in 2:
					var highest_cost = 0
					var chosen_unit = null
					
					for team in Main.teams:
						if team != active_team:
							for unit in team.units:
								if unit.cost > highest_cost:
									highest_cost = unit.cost
									chosen_unit = unit
					
					if chosen_unit != null:
						Main.teams[chosen_unit.team].units.erase(chosen_unit)
						Main.teams[chosen_unit.team].lost_units += 1
						active_team.add_unit(chosen_unit)
						chosen_unit.activate()
			gl.COS.BOSS:
				pass # no super for now (maybe no super at all, only power)
			_: # own team effects
				for unit in active_team.units:
					apply_super(unit, active_team.co)

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
	unit.set_aux_texture(power_up)
	match co:
		gl.COS.MARK0:
			unit.movement += 1
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod += 0.2
		gl.COS.BANDIT:
			if unit.id == gl.UNITS.LIGHT_INFANTRY or unit.id == gl.UNITS.HEAVY_INFANTRY:
				unit.atk_mod += 0.3
				unit.def_mod += 0.3
			else:
				unit.atk_mod += 0.1
				unit.def_mod += 0.1
		gl.COS.HUMAN_CO:
			unit.health += 2
		gl.COS.EVIL_MARK0:
			unit.atk_mod += 0.3
			unit.def_mod -= 0.3
			unit.movement += 2
		
func apply_super(unit: Unit, co: int):
	unit.set_aux_texture(power_up)
	match co:
		gl.COS.MARK0:
			unit.movement += 2
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod += 0.2
				var light_tank_unit_data = gl.units[gl.UNITS.LIGHT_TANK]
				unit.ammo = light_tank_unit_data.ammo
				unit.w1_dmg_chart = light_tank_unit_data.w1_dmg_chart
				unit.w1_can_attack = light_tank_unit_data.w1_can_attack
				unit.w2_dmg_chart = light_tank_unit_data.w2_dmg_chart
				unit.w2_can_attack = light_tank_unit_data.w2_can_attack
		gl.COS.BANDIT:
			if unit.id == gl.UNITS.LIGHT_INFANTRY or unit.id == gl.UNITS.HEAVY_INFANTRY:
				unit.atk_mod += 0.5
				unit.def_mod += 0.5
				unit.movement += 1
			else:
				unit.atk_mod += 0.2
				unit.def_mod += 0.2
		gl.COS.HUMAN_CO:
			unit.health += 2
			unit.atk_mod += 0.2
			unit.def_mod += 0.2

func remove_power(unit: Unit, co: int):
	unit.set_aux_texture(null)
	match co:
		gl.COS.MARK0:
			unit.movement -= 1
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod -= 0.2
		gl.COS.BANDIT:
			if unit.id == gl.UNITS.LIGHT_INFANTRY or unit.id == gl.UNITS.HEAVY_INFANTRY:
				unit.atk_mod -= 0.3
				unit.def_mod -= 0.3
			else:
				unit.atk_mod -= 0.1
				unit.def_mod -= 0.1
		gl.COS.EVIL_MARK0:
			unit.atk_mod -= 0.3
			unit.def_mod += 0.3
			unit.movement -= 2

func remove_super(unit: Unit, co: int):
	unit.set_aux_texture(null)
	match co:
		gl.COS.MARK0:
			unit.movement -= 2
			if unit.id == gl.UNITS.RECON:
				unit.atk_mod -= 0.2
				var recon_unit_data = gl.units[gl.UNITS.RECON]
				unit.ammo = recon_unit_data.ammo
				unit.w1_dmg_chart = recon_unit_data.w1_dmg_chart
				unit.w1_can_attack = recon_unit_data.w1_can_attack
				unit.w2_dmg_chart = recon_unit_data.w2_dmg_chart
				unit.w2_can_attack = recon_unit_data.w2_can_attack
		gl.COS.BANDIT:
			if unit.id == gl.UNITS.LIGHT_INFANTRY or unit.id == gl.UNITS.HEAVY_INFANTRY:
				unit.atk_mod -= 0.5
				unit.def_mod -= 0.5
				unit.movement -= 1 
			else:
				unit.atk_mod -= 0.2
				unit.def_mod -= 0.2
		gl.COS.HUMAN_CO:
			unit.atk_mod -= 0.2
			unit.def_mod -= 0.2
