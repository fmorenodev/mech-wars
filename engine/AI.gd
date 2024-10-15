#warning-ignore-all:unused_variable
extends Node

var current_index = 0

onready var Main = get_parent()

# final objectives: TODO 
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

# kinds of ai: TODO 
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
# - join : TODO

# TODO, corner cases:
# - move out of grey buildings (non-infantry)

# TODO:
# - don't have all units go towards the same objective when moving
# - finetune turn values
# - don't use power immediately

func _ready() -> void:
	var _err = signals.connect("start_ai_turn", self, "_on_start_turn")
	_err = signals.connect("next_ai_unit_turn", self, "_on_next_unit_turn")
	_err = signals.connect("end_ai_turn", self, "_on_end_ai_turn")
	
	_err = signals.connect("move_completed", self, "_on_move_completed")
	_err = signals.connect("action_completed", self, "_on_action_completed")

func _on_start_turn(team: Team) -> void:
	Main.disable_input(true)

	# calculate turn order
	for unit in team.units:
		calculate_turn(unit)
	
	# sort by turn value, the "best" turns happen first
	insertion_sort_by_turn_value(team.units)
	
	if !Main.active_team.units.empty():
		if Main.active_team.is_super_enabled:
			signals.emit_signal("super_start", Main.active_team)
		elif Main.active_team.is_power_enabled:
			signals.emit_signal("power_start", Main.active_team)
		else:
			signals.emit_signal("next_ai_unit_turn")
	else:
		signals.emit_signal("end_ai_turn", Main.active_team)

# TODO: refactor maybe
func _on_next_unit_turn() -> void:
	var unit = get_current()
	calculate_turn(unit) # recalculate to avoid conflicts
	var start_point = astar.a_star_maps[unit.team_id][unit.move_type].get_closest_point(Main.PathTileMap.world_to_map(unit.position))
	var path: Array = astar.a_star_maps[unit.team_id][unit.move_type].get_point_path(start_point, astar.a_star_maps[unit.team_id][unit.move_type].get_closest_point(Main.PathTileMap.world_to_map(unit.chosen_action[2])))
	if unit.chosen_action[1] == gl.TURN_TYPE.ATTACK:
		if !gl.is_indirect(unit):
			if !unit.chosen_action[2] == unit.position and !path.empty():
				Main.move_unit_ai(unit, path)
			else:
				signals.emit_signal("move_completed", unit)
		else:
			signals.emit_signal("move_completed", unit)
	
	elif unit.chosen_action[1] == gl.TURN_TYPE.CAPTURE:
		if !unit.chosen_action[2] == unit.position and !path.empty():
			Main.move_unit_ai(unit, path)
		else:
			signals.emit_signal("move_completed", unit)
	
	elif unit.chosen_action[1] == gl.TURN_TYPE.REPAIR:
		if !unit.chosen_action[2] == unit.position and !path.empty():
			Main.move_unit_ai(unit, path)
		else:
			signals.emit_signal("move_completed", unit)
	
	else: # unit.chosen_action[1] == gl.TURN_TYPE.MOVE
		if !unit.chosen_action[2] == unit.position and !unit.move_path.empty():
			Main.move_unit_ai(unit, unit.move_path)
		else:
			signals.emit_signal("move_completed", unit)

func _on_move_completed(unit: Unit) -> void:
	if unit.chosen_action[1] == gl.TURN_TYPE.ATTACK:
		Main.attack_unit_ai(unit, unit.chosen_target)
	
	elif unit.chosen_action[1] == gl.TURN_TYPE.CAPTURE:
		Main.capture_action_ai(unit)
	
	else:
		signals.emit_signal("action_completed")

# creates the most expensive unit it can afford on each building
func _on_end_ai_turn(team: Team) -> void:
	
	# only create certain units if the enemy is making units that need counters
	var enemy_team_units = []
	for t in Main.teams:
		if team.allegiance != t.allegiance:
			enemy_team_units.append_array(t.units)
	var enemy_air_units := 0
	var enemy_armored_units := 0
	var create_anti_air := false
	var create_anti_armored := false
	for enemy_unit in enemy_team_units:
		if enemy_unit.move_type == gl.MOVE_TYPE.AIR:
			enemy_air_units += 1
		elif enemy_unit.move_type == gl.MOVE_TYPE.HEAVY_VEHICLE or \
		enemy_unit.move_type == gl.MOVE_TYPE.LIGHT_VEHICLE:
			enemy_armored_units += 1
	if enemy_air_units >= 2:
		create_anti_air = true
	if enemy_armored_units >= 3:
		create_anti_armored = true
			
	for i in range(team.buildings.size() - 1, -1, -1): # start from the latest captured buildings
		var building = team.buildings[i]
		if (building.type == gl.BUILDINGS.FACTORY or building.type == gl.BUILDINGS.PORT or building.type == gl.BUILDINGS.AIRPORT) \
		and !Main.is_unit_in_position(Main.PathTileMap.world_to_map(building.position)):
			var highest_cost = 0
			var chosen_unit = null
			for unit_code in gl.units.keys():
				if building.available_units.has(unit_code):
					var unit = gl.units[unit_code]
					if unit.cost > highest_cost and team.funds >= unit.cost \
					and (team.unit_points + unit.point_cost) <= team.max_unit_points:
						if ((unit_code == gl.UNITS.ANTI_AIR or unit_code == gl.UNITS.ROCKET or \
						unit_code == gl.UNITS.ANGEL) and !create_anti_air) or \
						(unit_code == gl.UNITS.HEAVY_INFANTRY and !create_anti_armored):
							pass
						else:
							highest_cost = unit.cost
							chosen_unit = unit_code
					
			if chosen_unit != null:
				signals.emit_signal("unit_added", chosen_unit, team.team_id, building.position)
		# TODO: better unit creation
		# build unit according to map type, starting from most expensive and then creating basic units
		# or fill all buildings with units
	
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
			var value = 0
			if target.allegiance != unit.allegiance:
				value = Main.calc_dmg_value(unit, target)
				if target.capture_points > 0:
					value += 50
				if value > attack_turn_value:
					attack_turn_value = value
					chosen_target = target
					cell_to_move = target_pos[0]
	return [attack_turn_value, chosen_target, cell_to_move]

func calc_cap_points(unit: Unit, target: Building) -> float:
	var value
	if target.team_id == -1:
		value = 100
	elif target.allegiance != unit.allegiance:
		value = 150
	if target.type != gl.BUILDINGS.RUINS or target.type != gl.BUILDINGS.RUINS_2:
		value += 51
	return value

# TODO: if unit is capturing in more than p.e. five turns, retreat
func calc_capture_value(unit: Unit) -> Array:
	var capture_turn_value = 0
	var chosen_building = null
	if unit.can_capture:
		if unit.capture_points > 0:
			return [202, Main.is_building_in_position(Main.SelectionTileMap.world_to_map(unit.position))]
		var building_targets = Main.check_buildings(unit, false)
		for target_pos in building_targets:
			var target = Main.is_building_in_position(target_pos)
			var value = 0
			if target.team_id == -1:
				value = 100
			elif target.allegiance != unit.allegiance:
				value = 150
			if target.type != gl.BUILDINGS.RUINS or target.type != gl.BUILDINGS.RUINS_2:
				value += 51
			if value > capture_turn_value:
				capture_turn_value = value
				chosen_building = target
	return [capture_turn_value, chosen_building]

func calc_repair_points(unit: Unit) -> float:
	var value = 0
	if unit.cost / 5.0 < Main.active_team.funds / 2: # cost of repairing one turn is lower than half of income
		value = unit.cost / 1000.0 * 2
	return value

func calc_repair_value(unit: Unit) -> Array:
	var repair_turn_value = 0
	var chosen_repair_building = null
	var building_in_same_pos = Main.is_building_in_position(Main.SelectionTileMap.world_to_map(unit.position))
	if building_in_same_pos and building_in_same_pos.allegiance == unit.allegiance and unit.health <= 8:
		# TODO: if unit is repairing, allow it to take another action
		# find a way to prioritize actions taken on the same position without passing the turn
		pass
	if unit.health <= 2 or unit.ammo == 0 or unit.energy < 11:
		var repair_targets = Main.check_buildings(unit, true)
		for target_pos in repair_targets:
			var target = Main.is_building_in_position(target_pos)
			if target.type == gl.BUILDINGS.RUINS or target.type == gl.BUILDINGS.RUINS_2:
				if calc_repair_points(unit) > 0:
					# repair_turn_value = unit.cost / 1000.0 * 2
					repair_turn_value = 100
					chosen_repair_building = target
					break
	return [repair_turn_value, chosen_repair_building]

# TODO: better movement limitation with energy
func calc_movement(unit: Unit) -> Array:
	var unit_a_star = astar.a_star_maps[unit.team_id][unit.move_type]
	var starting_point = unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(unit.position))
	var possible_paths = []
	# MOVE TO ATTACK
	var attack_turn_value = 0
	var chosen_target = null
	for target_unit in Main.units:
		if unit.allegiance != target_unit.allegiance:
			var weight = astar.get_path_weight(unit.move_type, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(target_unit.position)), unit.team_id, true)
			if weight < 99 and weight > 0:
				var value = Main.calc_dmg_value(unit, target_unit)
				if value / weight > attack_turn_value:
					attack_turn_value = value
					chosen_target = target_unit
	# MOVE TO CAPTURE
	var capture_turn_value = 0
	var chosen_capture_building = null
	for target_building in Main.buildings:
		if unit.allegiance != target_building.allegiance:
			var weight = astar.get_path_weight(unit.move_type, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(target_building.position)), unit.team_id, true)
			if weight < 99 and weight > 0:
				var value = calc_cap_points(unit, target_building) / 2
				if value / weight > capture_turn_value:
					attack_turn_value = value
					chosen_capture_building = target_building
	# MOVE TO HEAL
	var repair_turn_value = 0
	var chosen_repair_building = null
	if unit.health <= 2:
		for target_building in Main.buildings:
			if unit.allegiance == target_building.allegiance:
				var weight = astar.get_path_weight(unit.move_type, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(target_building.position)), unit.team_id, true)
				if weight < 99 and weight > 0:
					var value = calc_repair_points(unit)
					if value / weight > capture_turn_value:
						attack_turn_value = value
						chosen_repair_building = target_building

	# CALCULATE BEST MOVEMENT
	if attack_turn_value > repair_turn_value and attack_turn_value > capture_turn_value and chosen_target != null:
		var path = astar.get_partial_path(unit, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_target.position)))
		if gl.is_indirect(unit):
			path.pop_back()
		return path
	elif capture_turn_value > attack_turn_value and capture_turn_value > repair_turn_value and chosen_capture_building != null:
		var path = astar.get_partial_path(unit, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_capture_building.position)))
		return path
	elif repair_turn_value > attack_turn_value and repair_turn_value > capture_turn_value and chosen_repair_building != null:
		var path = astar.get_partial_path(unit, starting_point, unit_a_star.get_closest_point(Main.PathTileMap.world_to_map(chosen_repair_building.position)))
		return path
	return []

func calculate_turn(unit: Unit) -> void:
	# ATTACK
		var attack_values = calc_target_value(unit)
		unit.attack_turn_value = attack_values[0]
		unit.chosen_target = attack_values[1]
		unit.cell_to_move = attack_values[2]
		
		# CAPTURE
		var capture_values = calc_capture_value(unit)
		unit.capture_turn_value = capture_values[0]
		unit.chosen_capture_building = capture_values[1]
		
		# RETREAT AND REPAIR
		var repair_values = calc_repair_value(unit)
		unit.repair_turn_value = repair_values[0]
		unit.chosen_repair_building = repair_values[1]
		
		# choose turn action and then compare
		var chosen_action_value = [unit.attack_turn_value, unit.capture_turn_value, unit.repair_turn_value].max()
		if unit.attack_turn_value > unit.repair_turn_value and unit.attack_turn_value > unit.capture_turn_value:
			unit.cell_to_move = Main.SelectionTileMap.map_to_world(unit.cell_to_move)
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.ATTACK, unit.cell_to_move]
		elif unit.capture_turn_value > unit.attack_turn_value and unit.capture_turn_value > unit.repair_turn_value:
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.CAPTURE, unit.chosen_capture_building.position]
		elif unit.repair_turn_value > unit.capture_turn_value and unit.repair_turn_value > unit.attack_turn_value:
			unit.chosen_action = [chosen_action_value, gl.TURN_TYPE.REPAIR, unit.chosen_repair_building.position]
		else:
			var path = calc_movement(unit)
			if path.empty():
				unit.cell_to_move = unit.position
			else:
				unit.cell_to_move = Main.SelectionTileMap.map_to_world(path.back())
			unit.move_path = path
			unit.chosen_action = [0, gl.TURN_TYPE.MOVE, unit.cell_to_move]

func _on_action_completed() -> void:
	if !Main.active_team.defeated: # prevents code from continuing execution when the player is dead
		Main.update_all_a_star()
		goto_next()

func get_current():
	return Main.active_team.units[current_index]

func goto_next() -> void:
	current_index += 1
	if current_index > len(Main.active_team.units) - 1:
		current_index = 0
		signals.emit_signal("end_ai_turn", Main.active_team)
	else:
		if !Main.active_team.units.empty():
			signals.emit_signal("next_ai_unit_turn")

func insertion_sort_by_turn_value(arr: Array) -> void: 
	for i in range(1, len(arr)):
		var key = arr[i]
		var j = i-1
		while j >= 0 and key.chosen_action[0] > arr[j].chosen_action[0]:
			# For ascending order, change key > arr[j] to key < arr[j]
			arr[j + 1] = arr[j]
			j = j - 1
			arr[j + 1] = key
