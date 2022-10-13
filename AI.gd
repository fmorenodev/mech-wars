#warning-ignore-all:unused_variable
extends Node

var units = []
var buildings = []

onready var Main = get_parent()

# final objectives: 
# - kill all enemy units
# - capture a building
# - defend a building

# short term goals
# - capture buildings in range
# - kill enemy units in range, calculating value and retaliation
# - advance troops
# - create new troops

# priority between units (advanced AI)
# - calculate "turn value" of each unit's optimal turn
# - make a copy of the board status and run the most optimal turn, then run each other turn again
# - if the turn values are better or in a certain threshold, or there are more > 0 turn values, do the turn
# - else, go with the second most optimal, then repeat until the best set of turns are chosen

# kinds of ai
# - aggresive
# - defensive
# - easy: will move forward and attack everything
# - hard: calculates best movement

# basic actions
# - move unit
# - create unit
# - attack unit
# - capture
# - retreat to heal


# TODO: not all units act on the turn, capture doesn't work or the values are low, move works sometimes,
# sometimes weight is not calculated properly, can also move to mountains for some reason

func _ready() -> void:
	var _err = signals.connect("start_ai_turn", self, "start_turn")

func start_turn(team: Team) -> void:
	Main.disable_input(true)
	for unit in team.units:
		var start_point = gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.position))
		
		# ATTACK
		var attack_values = calc_target_value(unit)
		var attack_turn_value = attack_values[0]
		var chosen_target = attack_values[1]
		
		# CAPTURE
		var capture_values = calc_capture_value(unit)
		var capture_turn_value = capture_values[0]
		var chosen_building = capture_values[1]
		
		# RETREAT AND REPAIR
		var repair_values = calc_repair_value(unit)
		var repair_turn_value = repair_values[0]
		var chosen_repair_building = repair_values[1]
		
		# MOVE
		if (attack_turn_value == 0 and capture_turn_value == 0 and repair_turn_value == 0):
			calc_movement(unit)
			break
		
		# CALCULATE BEST TURN VALUE and execute action
		if attack_turn_value > repair_turn_value and attack_turn_value > capture_turn_value:
			if !gl.is_indirect(unit):
				var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_target.position)))
				path.pop_back()
				Main.move_unit_ai(unit, path)
			Main.attack_unit_ai(unit, chosen_target)
			unit.end_action()
		
		elif capture_turn_value >= attack_turn_value and capture_turn_value > repair_turn_value:
			var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_building.position)))
			path.pop_back()
			Main.move_unit_ai(unit, path)
			Main.capture_action()
		
		elif repair_turn_value >= capture_turn_value and repair_turn_value >= attack_turn_value:
			var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_repair_building.position)))
			path.pop_back()
			Main.move_unit_ai(unit, path)
		
		Main.update_a_star()
		
		# TODO: maybe yield until end of turn?
	for building in team.buildings:
		if building.type != gl.BUILDINGS.RUINS or building.type != gl.BUILDINGS.RUINS_2:
			signals.emit_signal("unit_added", gl.UNITS.LIGHT_INFANTRY, team, building.position)
		# build unit according to map type, starting from most expensive and then creating basic units
		# or fill all buildings with units
		pass
	Main.disable_input(false)
	signals.emit_signal("turn_ended")

func calc_target_value(unit: Unit) -> Array:
	var attack_turn_value = 0
	var chosen_target = null
	if unit.atk_type != -1: # can attack
		var targets = Main.check_all_targets(unit)
		for target_pos in targets:
			var target = Main.is_unit_in_position(target_pos)
			# TODO: add value modifiers, for example:
			# unit is capturing -> much more value
			var value = Main.calc_dmg_value(unit, target)
			if value > attack_turn_value:
				attack_turn_value = value
				chosen_target = target
	return [attack_turn_value, chosen_target]

func calc_capture_value(unit: Unit) -> Array:
	var capture_turn_value = 0
	var chosen_building = null
	if unit.can_capture:
		var building_targets = Main.check_buildings(unit, false) # TODO: doesnt work correctly
		for target_pos in building_targets:
			var target = Main.is_building_in_position(target_pos)
			var value = 0
			if target.team == -1:
				value = 100
			elif target.team != unit.team:
				value = 150
			if target.type != gl.BUILDINGS.RUINS or target.type != gl.BUILDINGS.RUINS_2:
				value += 51
			if value > capture_turn_value:
				capture_turn_value = value
				chosen_building = target
	return [capture_turn_value, chosen_building]

func calc_repair_value(unit: Unit) -> Array:
	var repair_turn_value = 0
	var chosen_repair_building = null
	if unit.health <= 2:
		var repair_targets = Main.check_buildings(unit, true)
		for target_pos in repair_targets:
			var target = Main.is_building_in_position(target_pos)
			if target.type == gl.BUILDINGS.RUINS or target.type == gl.BUILDINGS.RUINS_2:
				if unit.cost / 5.0 < Main.active_team.buildings * 500:
					repair_turn_value = unit.cost / 1000.0 * 2
					chosen_repair_building = target
					break
	return [repair_turn_value, chosen_repair_building]

# TODO: consider retreat and capture
func calc_movement(unit: Unit) -> void:
	var starting_point = gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.position))
	var possible_paths = []
	# MOVE TO ATTACK
	var attack_turn_value = 0
	var chosen_target = null
	for target_unit in Main.units:
		if unit.team != target_unit.team:
			var weight = Main.get_path_weight(starting_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(target_unit.position)), true)
			if weight < 99:
				var value = Main.calc_dmg_value(unit, target_unit)
				if value / weight > attack_turn_value:
					attack_turn_value = value
					chosen_target = target_unit
	# TODO: add random move if for some reason there are no objectives
	if chosen_target != null:
		var path = Main.get_partial_path(starting_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_target.position)), unit.movement)
		Main.move_unit_ai(unit, path)
