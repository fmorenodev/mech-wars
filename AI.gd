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

# TODO:
# calculate all values at once, and then reevaluate them against each other,
# if target + destination are the same for two or more units
# then the one with the highest value picks that turn, then recalculate for the units that can't make that movement
# until all turns have been decided, then run the turns in order of value / or combat, then cap, then move

func _ready() -> void:
	var _err = signals.connect("start_ai_turn", self, "start_turn")

func start_turn(team: Team) -> void:
	Main.disable_input(true)
	var turn_conflicts = []
	for unit in team.units:
		calculate_turn(unit)
	
	for unit in team.units:
		for other_unit in team.units:
			if unit.chosen_action[2] == other_unit.chosen_action[2]:
				turn_conflicts.append([unit, other_unit])
	
	# turn_conflicts = gl.delete_duplicates(turn_conflicts)
	for conflict in turn_conflicts: # TODO: recalculate turn, without taking the same action
		if conflict[0].chosen_action[0] >= conflict[1].chosen_action[0]:
			pass
		else:
			pass
		
	for unit in team.units:
		var start_point = gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.position))
		# MOVE
		if (unit.attack_turn_value == 0 and unit.capture_turn_value == 0 and unit.repair_turn_value == 0):
			calc_movement(unit)
		else:
			# CALCULATE BEST TURN VALUE and execute action
			if unit.attack_turn_value > unit.repair_turn_value and unit.attack_turn_value > unit.capture_turn_value:
				if !gl.is_indirect(unit):
					# var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_target.position)))
					var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(unit.cell_to_move))
					# path.pop_back()
					move_unit(unit, path)
				Main.attack_unit_ai(unit, unit.chosen_target)
			
			elif unit.capture_turn_value >= unit.attack_turn_value and unit.capture_turn_value > unit.repair_turn_value:
				var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.chosen_building.position)))
				#path.pop_back()
				move_unit(unit, path)
				Main.capture_action_ai(unit)
			
			elif unit.repair_turn_value >= unit.capture_turn_value and unit.repair_turn_value >= unit.attack_turn_value:
				var path: Array = gl.a_star.get_point_path(start_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.chosen_repair_building.position)))
				#path.pop_back()
				move_unit(unit, path)
				unit.end_action()
		
		Main.update_a_star()

	for building in team.buildings:
		if (building.type != gl.BUILDINGS.RUINS or building.type != gl.BUILDINGS.RUINS_2) and !Main.is_unit_in_position(Main.PathTileMap.world_to_map(building.position)):
			signals.emit_signal("unit_added", gl.UNITS.LIGHT_INFANTRY, team.color, building.position)
		# build unit according to map type, starting from most expensive and then creating basic units
		# or fill all buildings with units
		pass
	Main.disable_input(false)
	signals.emit_signal("turn_ended")

func calc_target_value(unit: Unit) -> Array:
	var attack_turn_value = 0
	var chosen_target = null
	var cell_to_move = null
	if unit.atk_type != -1: # can attack
		var targets = Main.check_all_targets(unit)
		for target_pos in targets:
			var target = Main.is_unit_in_position(target_pos[1])
			# TODO: add value modifiers, for example:
			# unit is capturing -> much more value
			var value = Main.calc_dmg_value(unit, target)
			if value > attack_turn_value:
				attack_turn_value = value
				chosen_target = target
				cell_to_move = target_pos[0]
	return [attack_turn_value, chosen_target, cell_to_move]

func calc_capture_value(unit: Unit) -> Array:
	var capture_turn_value = 0
	var chosen_building = null
	if unit.can_capture:
		if unit.capture_points > 0:
			return [999999, Main.is_building_in_position(Main.SelectionTileMap.world_to_map(unit.position))]
		var building_targets = Main.check_buildings(unit, false)
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

# TODO: consider retreat
func calc_movement(unit: Unit) -> void:
	var starting_point = gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.position))
	var possible_paths = []
	# MOVE TO ATTACK
	var attack_turn_value = 0
	var chosen_target = null
	for target_unit in Main.units:
		if unit.team != target_unit.team:
			var weight = Main.get_path_weight(starting_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(target_unit.position)), true)
			if weight < 99 and weight > 0:
				var value = Main.calc_dmg_value(unit, target_unit)
				if value / weight > attack_turn_value:
					attack_turn_value = value
					chosen_target = target_unit
	# TODO: add random move if for some reason there are no objectives, or just stay in place
	if chosen_target != null:
		var path = Main.get_partial_path(starting_point, gl.a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_target.position)), unit.movement)
		if unit.atk_type == gl.ATTACK_TYPE.ARTILLERY: # TODO: improve
			path.pop_back()
		var path_world_coords = Main.move_unit_ai(unit, path)
		unit.walk_along(path_world_coords)
		yield(unit, "walk_finished")
		unit.position = path_world_coords.back()

func calculate_turn(unit):
	# ATTACK
		var attack_values = calc_target_value(unit)
		unit.attack_turn_value = attack_values[0]
		unit.chosen_target = attack_values[1]
		unit.cell_to_move = attack_values[2]
		
		# CAPTURE
		var capture_values = calc_capture_value(unit)
		unit.capture_turn_value = capture_values[0]
		unit.chosen_building = capture_values[1]
		
		# RETREAT AND REPAIR
		var repair_values = calc_repair_value(unit)
		unit.repair_turn_value = repair_values[0]
		unit.chosen_repair_building = repair_values[1]
		
		# MOVE
		#var move_values = calc_movement(unit)
		#unit.move_turn_value = move_values[0]
		#unit.chosen_cell_movement = move_values[1]
	
		# choose turn action and then compare
		var chosen_action_value = [unit.attack_turn_value, unit.capture_turn_value, unit.repair_turn_value].max()
		if unit.attack_turn_value > unit.repair_turn_value and unit.attack_turn_value > unit.capture_turn_value:
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.ATTACK, unit.cell_to_move]
		elif unit.capture_turn_value > unit.attack_turn_value and unit.capture_turn_value > unit.repair_turn_value:
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.CAPTURE, unit.chosen_building.position]
		elif unit.repair_turn_value > unit.capture_turn_value and unit.repair_turn_value > unit.attack_turn_value:
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.REPAIR, unit.chosen_repair_building.position]
		else:
			unit.chosen_action = [0, gl.TURN_TYPE.MOVE, Vector2.ZERO] # TODO: calc movement before moving]

func move_unit(unit, path):
	var path_world_coords = Main.move_unit_ai(unit, path)
	unit.walk_along(path_world_coords)
	yield(unit, "walk_finished")
	unit.position = path_world_coords.back()
