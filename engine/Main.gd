extends Node2D

onready var CursorTileMap: TileMap = $Map/CursorTileMap
onready var SelectionTileMap: TileMap = $Map/SelectionTileMap
onready var TerrainTileMap: TileMap = $Map/TerrainTileMap
onready var BuildingsTileMap: TileMap = $Map/BuildingsTileMap
onready var PathTileMap: PathTileMap = $Map/PathTileMap
onready var ActionMenu: PopupMenu = $GUI/GUIContainer/ActionMenu
onready var GameMenu: PopupMenu = $GUI/GUIContainer/GameMenu
onready var BuildingMenu: PopupMenu = $GUI/GUIContainer/BuildingMenu
onready var COPowers: Node = $COPowers

const Team = preload("res://entities/Team.gd")
const UnitScene = preload("res://entities/Unit.tscn")

var active_team: Team
var active_unit: Unit
var walkable_cells := []
var units := []
var buildings := []
var teams := []
var action_menu_open := false
var targets := []
var selecting_targets := false
var current_index: int
var day: int

var is_ffa := true

##################
# INITIALIZATION #
##################

func initialize(new_teams: Array) -> void:
	randomize()
	CursorTileMap.cursor_pos = Vector2.ZERO
	CursorTileMap.set_cellv(CursorTileMap.cursor_pos, 0)
	units.clear()
	buildings.clear()
	targets.clear()
	teams = new_teams
	active_team = teams[0]
	current_index = 0
	day = 0

func _ready() -> void:
	# TODO: change this for window mode, but right now it makes the tile system kinda break
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var cells = TerrainTileMap.get_used_cells()
	gl.map_size = cells.back() + Vector2.ONE
	var _err = signals.connect("accept_pressed", self, "_on_accept_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	_err = signals.connect("cursor_moved", self, "_on_cursor_moved")
	
	_err = signals.connect("move_action", self, "_on_move_action")
	_err = signals.connect("cancel_action", self, "_on_cancel_action")
	_err = signals.connect("attack_action", self, "_on_attack_action")
	_err = signals.connect("capture_action", self, "_on_capture_action")
	_err = signals.connect("join_action", self, "_on_join_action")
	
	_err = signals.connect("target_selected", self, "_on_target_selected")
	_err = signals.connect("unit_added", self, "_on_unit_added")
	_err = signals.connect("unit_deleted", self, "_on_unit_deleted")
	_err = signals.connect("turn_ended", self, "_on_turn_ended")

	# allegiances here
	initialize([Team.new(gl.TEAM.RED, true, 0), Team.new(gl.TEAM.BLUE, false, 1)])
	
	teams[0].co = gl.COS.HUMAN_CO
	teams[1].co = gl.COS.MARK0
	
	for unit in SelectionTileMap.get_children():
		add_unit_data(unit, unit.id, teams[unit.team_id])
		unit.change_material_to_color()
	for building in BuildingsTileMap.get_children():
		add_building_data(building, building.type, building.team_id)
	
	# game setup
	is_ffa = true
	
	astar.init_a_star()
	start_turn()

func create_unit(unit_id: int, team: Team, position: Vector2) -> void:
	var new_unit = UnitScene.instance()
	SelectionTileMap.add_child(new_unit)
	new_unit.position = position
	add_unit_data(new_unit, unit_id, team)
	if (team.is_power_active):
		COPowers.apply_power(new_unit, team.co)
	if (team.is_super_active):
		COPowers.apply_super(new_unit, team.co)

func add_unit_data(unit: Unit, unit_id: int, team: Team) -> void:
	unit.initialize(unit_id)
	units.append(unit)
	unit.set_team(team.team_id)
	unit.set_co(team.co)
	unit.max_health = team.unit_max_health
	unit.allegiance = team.allegiance
	team.add_unit(unit)
	team.unit_points += gl.units[unit_id].point_cost
	unit.end_action()

func add_building_data(building: Building, type: int, team_id: int, available_units: PoolIntArray = []):
	building.initialize(type, team_id, teams[team_id].unlocked_factory_units, available_units)
	if building.type == gl.BUILDINGS.RESEARCH_2:
		var atk_power_mod = PowerMod.new(gl.POWER_MOD.ATK_MOD, 0.05)
		var cap_power_mod = PowerMod.new(gl.POWER_MOD.CAP_MOD, 0.5)
		var funds_mod = PowerMod.new(gl.POWER_MOD.FUNDS, 2000.0)
		building.power_mods = [atk_power_mod, cap_power_mod, funds_mod]
	buildings.append(building)
	if team_id >= 0:
		building.capture(teams[team_id])
		teams[team_id].add_building(building)

##############
# A* FUNCTIONS
##############

func update_all_a_star() -> void:
	for team in teams:
		for a_star in astar.a_star_maps[team.team_id]:
			update_a_star(a_star, team.team_id)

func update_a_star(a_star: AStar2D, team_id: int) -> void:
	for x in gl.map_size.x:
		for y in gl.map_size.y:
			var pos = Vector2(x, y)
			var unit_in_position = is_unit_in_position(pos)
			if unit_in_position:
				if unit_in_position.allegiance != teams[team_id].allegiance:
					var point = a_star.get_closest_point(pos)
					a_star.add_point(point, pos, 99)
				else:
					astar.update_point(a_star, a_star.get_closest_point(pos), pos, team_id)
			else:
				astar.update_point(a_star, a_star.get_closest_point(pos), pos, team_id)

func get_walkable_cells(unit: Unit) -> Array:
	return astar.flood_fill(unit.move_type, TerrainTileMap.world_to_map(unit.position), int(min(unit.movement, unit.energy)), unit.team_id)

##########################
# TILE ACTIONS FUNCTIONS # 
##########################

func select_unit() -> void:
	active_unit.is_selected = true
	walkable_cells = get_walkable_cells(active_unit)
	for pos in walkable_cells:
		SelectionTileMap.set_cellv(pos, 0)

func deselect_active_unit() -> void:
	active_unit.is_selected = false
	SelectionTileMap.clear()
	PathTileMap.clear()

func clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()

func check_targets(unit: Unit, pos: Vector2, all_possible: bool = false) -> Array:
	var result := []
	var directions := []
	match unit.atk_type:
		gl.ATTACK_TYPE.DIRECT:
			directions = gl.DIRECTIONS
		gl.ATTACK_TYPE.ARTILLERY:
			directions = gl.IND_DIRECTIONS_ARTILLERY
		gl.ATTACK_TYPE.HEAVY_ARTILLERY:
			directions = gl.IND_DIRECTIONS_HEAVY_ARTILLERY
	for direction in directions:
		var coordinates: Vector2 = TerrainTileMap.world_to_map(pos) + direction
		var target_unit = is_unit_in_position(coordinates)
		if all_possible or (target_unit and target_unit.allegiance != unit.allegiance and can_attack(unit, target_unit)):
			result.append(coordinates)
	return result

# returns [cell that the unit can move to, cell with a target]
func check_all_targets(unit: Unit) -> Array:
	if gl.is_indirect(unit):
		var th_cells = check_targets(unit, unit.position)
		var unit_pos = unit.position
		for i in th_cells.size():
			th_cells[i] = [unit_pos, th_cells[i]]
		return th_cells
	else:
		var wk_cells = get_walkable_cells(unit)
		for i in range(wk_cells.size() - 1, -1, -1):
			if is_unit_in_position(wk_cells[i]):
				wk_cells.remove(i)
		var th_cells: Array = []
		for cell in wk_cells:
			var tgs = check_targets(unit, SelectionTileMap.map_to_world(cell))
			for target in tgs:
				th_cells.append([cell, target])
		th_cells = gl.delete_duplicates_unordered_matrix(th_cells)
		return th_cells

func threatened_cells(unit: Unit) -> Array:
	var th_cells := []
	if gl.is_indirect(unit):
		match unit.atk_type:
			gl.ATTACK_TYPE.ARTILLERY:
				for dir in gl.IND_DIRECTIONS_ARTILLERY:
					th_cells.append(dir + SelectionTileMap.world_to_map(unit.position))
			gl.ATTACK_TYPE.HEAVY_ARTILLERY:
				for dir in gl.IND_DIRECTIONS_HEAVY_ARTILLERY:
					th_cells.append(dir + SelectionTileMap.world_to_map(unit.position))
	else:
		var wk_cells = get_walkable_cells(unit)
		for i in range(wk_cells.size() - 1, -1, -1):
			var unit_in_pos = is_unit_in_position(wk_cells[i])
			if unit_in_pos:
				if unit.allegiance != unit_in_pos.allegiance:
					wk_cells.remove(i)
		for cell in wk_cells:
			var tgs = check_targets(unit, SelectionTileMap.map_to_world(cell), true)
			th_cells = th_cells + tgs
		th_cells = th_cells + wk_cells
		th_cells = gl.delete_duplicates(th_cells)
		for i in range(th_cells.size() - 1, -1, -1):
			if gl.is_off_borders(th_cells[i]):
				th_cells.remove(i)
	return th_cells

func check_buildings(unit: Unit, owned: bool) -> Array:
	var buildings_result := []
	var wk_cells = get_walkable_cells(unit)
	for i in range(wk_cells.size() - 1, -1, -1):
		if is_unit_in_position(wk_cells[i]) and SelectionTileMap.world_to_map(unit.position) != wk_cells[i]:
			wk_cells.remove(i)
	for cell in wk_cells:
		var building = is_building_in_position(cell)
		if building:
			if (!owned and building.allegiance != unit.allegiance) or (owned and building.allegiance == unit.allegiance):
				buildings_result.append(cell)
	return buildings_result

func select_unit_or_building(pos: Vector2) -> void:
	SelectionTileMap.clear()
	close_menus()
	var selected_entity = is_unit_or_building_in_position(pos)
	if selected_entity is Unit:
		active_unit = selected_entity
		if active_unit.can_move:
			select_unit()
		else:
			var th_cells = threatened_cells(selected_entity)
			for pos in th_cells:
				SelectionTileMap.set_cellv(pos, 1)
			active_unit = null
	elif selected_entity is Building and selected_entity.team_id == active_team.team_id \
	and selected_entity.is_production_building():
		open_building_menu(selected_entity)
	else:
		open_game_menu()

func move_active_unit(target_pos: Vector2) -> void:
	var unit_blocking = is_unit_in_position(target_pos)
	var can_join := false
	if unit_blocking and (unit_blocking != active_unit):
		if unit_blocking.id == active_unit.id:
			targets = [unit_blocking]
			can_join = true
		else:
			return
	if not target_pos in walkable_cells: # empty
		return
	
	if PathTileMap.map_to_world(target_pos) == active_unit.position:
		deselect_active_unit()
		targets = check_targets(active_unit, active_unit.position)
	else:
		# movement
		disable_input(true)
		active_unit.last_pos = active_unit.position
		deselect_active_unit()
		var path_world_coords = []
		for point in PathTileMap.current_path:
			path_world_coords.append(PathTileMap.map_to_world(point))
		active_unit.walk_along(path_world_coords)
		yield(active_unit, "walk_finished")
		active_unit.current_energy_cost = path_world_coords.size() - 1
		disable_input(false)
		active_unit.position = path_world_coords.back()
	
	if can_join:
		open_action_menu([4], target_pos) # join
		return
	# check for attack targets
	if active_unit.atk_type == gl.ATTACK_TYPE.DIRECT:
		targets = check_targets(active_unit, active_unit.position)
	
	# build action menu
	var menu_options = []
	if !targets.empty():
		menu_options.append(2) # attack
	var building = is_building_in_position(target_pos)
	if building and active_unit.can_capture and building.allegiance != active_team.allegiance:
		menu_options.append(3) # capture
	else:
		active_unit.capture_points = 0
		active_unit.AuxLabel.text = ''
	open_action_menu(menu_options, target_pos)

func open_action_menu(menu_options: PoolIntArray, pos: Vector2) -> void:
	action_menu_open = true
	ActionMenu.generate_menu(menu_options)
	ActionMenu.rect_position = TerrainTileMap.map_to_world(pos) + Vector2(gl.tile_size, gl.tile_size)
	ActionMenu.show()

func open_building_menu(building: Building) -> void:
	BuildingMenu.generate_menu(building.available_units, active_team.funds, active_team, building.position)
	if BuildingMenu.get_item_count() > 0:
		BuildingMenu.show()
		GameMenu.hide()

func open_game_menu() -> void:
	GameMenu.show()
	BuildingMenu.hide()

func close_menus() -> void:
	GameMenu.hide()
	BuildingMenu.hide()

# AI auxiliar functions

func move_unit_ai(unit: Unit, path: Array) -> void:
	var path_world_coords = []
	for point in path:
		path_world_coords.append(PathTileMap.map_to_world(point))
	unit.walk_along(path_world_coords)
	yield(unit, "walk_finished")
	unit.position = path_world_coords.back()
	unit.energy -= path.size() - 1
	signals.emit_signal("move_completed", unit)

func attack_unit_ai(attacker_unit: Unit, target_unit: Unit) -> void:
	CursorTileMap.set_cellv(CursorTileMap.world_to_map(target_unit.position), 1)
	yield(get_tree().create_timer(1.0), "timeout")
	
	common_attack_logic(attacker_unit, target_unit)
	
	CursorTileMap.set_cellv(CursorTileMap.world_to_map(target_unit.position), -1)
	attacker_unit.end_action()
	signals.emit_signal("action_completed")

func capture_action_ai(unit: Unit) -> void:
	common_capture_logic(unit)
	signals.emit_signal("action_completed")

##########################
# TILE CHECKER FUNCTIONS #
##########################

func is_unit_in_position(pos: Vector2):
	var global_pos = SelectionTileMap.map_to_world(pos)
	for unit in units:
		if unit.position == global_pos:
			return unit
	return false

func is_building_in_position(pos: Vector2):
	var global_pos = BuildingsTileMap.map_to_world(pos)
	for building in buildings:
		if building.position == global_pos:
			return building
	return false

func is_unit_or_building_in_position(pos: Vector2):
	var result = is_unit_in_position(pos)
	if result:
		return result
	else:
		return is_building_in_position(pos)

####################
# SIGNAL FUNCTIONS #
####################

func _on_accept_pressed(pos: Vector2) -> void:
	if not active_unit:
		select_unit_or_building(pos)
	elif active_unit.is_selected:
		move_active_unit(pos)

func _on_cancel_pressed() -> void:
	if action_menu_open:
		_on_cancel_action()
	elif active_unit:
		deselect_active_unit()
		clear_active_unit()
	else:
		SelectionTileMap.clear()

func _on_cursor_moved(target_pos: Vector2) -> void:
	if active_unit and active_unit.is_selected:
		PathTileMap.draw(PathTileMap.world_to_map(active_unit.position), target_pos, active_unit)

func _on_move_action() -> void:
	end_unit_action()

func _on_cancel_action() -> void:
	if active_unit.last_pos != null:
		active_unit.position = active_unit.last_pos
	select_unit()
	action_menu_open = false
	if selecting_targets:
		selecting_targets = false
		for target in targets:
			CursorTileMap.set_cellv(target, -1)
	targets = []

func _on_attack_action() -> void:
	if !targets.empty():
		selecting_targets = true
		CursorTileMap.move_cursor(targets[0])
		CursorTileMap.set_cellv(targets[0], 1)

func _on_capture_action() -> void:
	common_capture_logic(active_unit)
	end_unit_action()

func _on_join_action() -> void:
	var joining_unit: Unit = targets[0]
	active_unit.joined_this_turn = true
	
	var new_ammo = clamp(active_unit.ammo + joining_unit.ammo, -1, gl.units[active_unit.id].ammo)
	var new_energy = clamp(active_unit.energy - active_unit.current_energy_cost + joining_unit.energy,
		0, gl.units[active_unit.id].energy)
	var new_health = active_unit.health + joining_unit.health
	if new_health > active_unit.max_health:
		active_team.funds += (new_health - active_unit.max_health) * active_unit.cost / active_unit.max_health
	
	if joining_unit.capture_points > 0:
		active_unit.capture_points = joining_unit.capture_points
		active_unit.capturing_building = joining_unit.capturing_building
		active_unit.AuxLabel.text = 'c'
	
	active_unit.ammo = new_ammo
	active_unit.energy = new_energy
	active_unit.health = new_health
	joining_unit.health = 0
	targets.clear()
	end_unit_action()

# TODO: can select an empty target when attacking (unsure if solved)
func _on_target_selected(pos: Vector2) -> void:
	var target_unit: Unit = is_unit_in_position(pos)
	
	common_attack_logic(active_unit, target_unit)
	
	targets = []
	selecting_targets = false
	end_unit_action()

func _on_unit_added(unit_id: int, team_id: int, position: Vector2) -> void:
	create_unit(unit_id, teams[team_id], position)
	teams[team_id].funds -= gl.units[unit_id].cost

func _on_unit_deleted(unit: Unit) -> void:
	var team: Team = teams[unit.team_id]
	units.erase(unit)
	team.units.erase(unit)
	team.lost_units += 1
	team.unit_points -= unit.point_cost
	unit.queue_free()
	if team.units.size() <= 0:
		team.defeated = true
		signals.emit_signal("team_defeated", team)

func _on_turn_ended() -> void:
	for unit in active_team.units:
		unit.end_turn()
	current_index += 1
	if current_index >= teams.size():
		current_index = 0
	active_team = teams[current_index]
	start_turn()

#################
# AUX FUNCTIONS #
#################

func common_capture_logic(unit: Unit) -> void:
	var building = is_building_in_position(SelectionTileMap.world_to_map(unit.position))
	unit.capture(building)
	if unit.capture_points >= 20:
		unit.capture_points = 0
		teams[building.team_id].buildings.erase(building)
		if building.team_id != -1:
			building.capture(active_team, teams[building.team_id])
		else:
			building.capture(active_team)
		active_team.add_building(building)

func common_attack_logic(attacker_unit: Unit, target_unit: Unit) -> void:
	var damage = calc_damage(attacker_unit, target_unit)
	var extra_damage = special_attack_cases(attacker_unit, target_unit)
	var retaliation_damage = calc_retaliation_damage(target_unit, attacker_unit, damage)
	
	attacker_unit.health = attacker_unit.health - retaliation_damage + damage * attacker_unit.lifesteal
	target_unit.health = target_unit.health - damage + retaliation_damage * target_unit.lifesteal
	if attacker_unit.fund_salvaging > 0:
		teams[attacker_unit.team_id].funds += attacker_unit.fund_salvaging * damage * (target_unit.cost / 10.0)
	if target_unit.fund_salvaging > 0:
		teams[target_unit.team_id].funds += target_unit.fund_salvaging * retaliation_damage * (attacker_unit.cost / 10.0)
	
	if extra_damage > 0.0:
		attacker_unit.health += extra_damage * attacker_unit.lifesteal
		# teams[attacker_unit.team_id].funds += attacker_unit.fund_salvaging * extra_damage * (target_unit.cost / 1000.0)

# unit attack abilities
func special_attack_cases(attacker_unit: Unit, target_unit: Unit) -> float:
	var extra_damage := 0.0
	match attacker_unit.id:
		gl.UNITS.ARC_TOWER:
			var target_pos := target_unit.position
			var selected_targets = [target_unit]
			for i in 3:
				var possible_targets = []
				for direction in gl.DIRECTIONS:
					var coordinates: Vector2 = TerrainTileMap.world_to_map(target_pos) + direction
					var possible_target = is_unit_in_position(coordinates)
					if possible_target and possible_target.allegiance != attacker_unit.allegiance \
					and !selected_targets.has(possible_target):
						possible_targets.append(possible_target)
				if possible_targets.size() > 0:
					var new_target_unit: Unit = possible_targets[0]
					target_pos = new_target_unit.position
					var damage = calc_damage(attacker_unit, new_target_unit)
					extra_damage += damage
					new_target_unit.health -= damage
					attacker_unit.ammo += 1
					if new_target_unit:
						selected_targets.append(new_target_unit)
				else:
					return extra_damage
			return extra_damage
		_:
			return extra_damage

func get_terrain(pos: Vector2) -> int:
	var map_pos = TerrainTileMap.world_to_map(pos)
	return TerrainTileMap.get_cellv(map_pos)

func get_terrain_stars(pos: Vector2) -> int:
	var map_pos = TerrainTileMap.world_to_map(pos)
	var tile_id = TerrainTileMap.get_cellv(map_pos)
	if is_building_in_position(map_pos):
		return 3
	else:
		return gl.terrain[tile_id].stars

# since add_random is only false when calculating dmg value, if add_random is true
# and w1 is used, ammo is substracted in this function
func calc_damage(attacker: Unit, target: Unit, add_random: bool = true) -> float:
	if can_attack(attacker, target):
		var wpn_used
		if can_use_w1(attacker, target):
			wpn_used = attacker.w1_dmg_chart[target.id]
			if add_random:
				attacker.ammo -= 1
		else:
			wpn_used = attacker.w2_dmg_chart[target.id]
		var attack_value = (wpn_used * (attacker.health / 10.0) * (attacker.atk_bonus) \
			* (attacker.atk_mod)) / 10.0
		if add_random:
			attack_value += (randi() % 11 * attacker.health / 10.0) / 10.0
		var terrain_stars = 0
		if target.move_type != gl.MOVE_TYPE.AIR:
			terrain_stars = get_terrain_stars(target.position)
		var def_value = (100.0 - (terrain_stars * target.health) * (target.def_bonus) \
			* (target.def_mod)) / 100.0
		var result = attack_value * def_value
		# meter calculation
		if add_random:
			teams[attacker.team_id].power_meter_amount += (target.cost * (result / 10)) / 2
			teams[target.team_id].power_meter_amount += target.cost * (result / 10)
		return stepify(result, 0.01)
	else:
		return 0.0

func calc_retaliation_damage(counter_attacker: Unit, target: Unit, dmg_suffered: int, add_random: bool = true) -> float:
	if counter_attacker and counter_attacker.atk_type == gl.ATTACK_TYPE.DIRECT \
		and target.atk_type == gl.ATTACK_TYPE.DIRECT and can_attack(counter_attacker, target):
		var wpn_used
		if can_use_w1(counter_attacker, target):
			wpn_used = counter_attacker.w1_dmg_chart[target.id]
			if add_random:
				counter_attacker.ammo -= 1
		else:
			wpn_used = counter_attacker.w2_dmg_chart[target.id]
		var attack_value = (wpn_used * ((counter_attacker.health - dmg_suffered) / 10.0) \
			* (counter_attacker.atk_bonus) * (counter_attacker.atk_mod)) / 10.0
		if add_random:
			attack_value += (randi() % 11 * (counter_attacker.health - dmg_suffered) / 10.0) / 10.0
		var terrain_stars = 0
		if target.move_type != gl.MOVE_TYPE.AIR:
			terrain_stars = get_terrain_stars(target.position)
		var def_value = (100.0 - (terrain_stars * target.health) * (target.def_bonus) \
			* (target.def_mod)) / 100.0
		var result = attack_value * def_value
		# meter calculation
		if add_random:
			teams[counter_attacker.team_id].power_meter_amount += (target.cost * (result / 10)) / 2
			teams[target.team_id].power_meter_amount += target.cost * (result / 10)
		if result < 0.0:
			result = 0.0
		return stepify(result, 0.01)
	else:
		return 0.0

func calc_dmg_value(attacker: Unit, target: Unit) -> int:
	var dmg = calc_damage(attacker, target, false)
	var retaliation_dmg = calc_retaliation_damage(target, attacker, dmg, false)
	var value = dmg * (target.cost / 1000.0) - retaliation_dmg * (attacker.cost / 1000.0)
	return value

func can_attack(attacker: Unit, target: Unit) -> bool:
	if attacker.w1_can_attack.has(target.id) and attacker.ammo > 0 \
		or attacker.w2_can_attack.has(target.id):
		return true
	else:
		return false

func can_use_w1(attacker: Unit, target: Unit) -> bool:
	return attacker.w1_can_attack.has(target.id) and attacker.ammo > 0

func start_turn() -> void:
	if active_team.team_id == 0:
		day += 1
	active_team.calculate_funds_per_turn()
	active_team.funds += active_team.funds_per_turn
	signals.emit_signal("turn_started", active_team)
	var units_to_delete = []
	for unit in active_team.units:
		unit.activate()
		var is_building = is_building_in_position(BuildingsTileMap.world_to_map(unit.position))
		if is_building and is_building.can_repair(unit):
			is_building.repair(unit, active_team)
		elif get_terrain(unit.position) == gl.TERRAIN.ENERGY_RELAY and unit.move_type != gl.MOVE_TYPE.AIR:
			unit.atk_bonus = 1.2
		elif get_terrain(unit.position) == gl.TERRAIN.SCRAPYARD and unit.move_type != gl.MOVE_TYPE.AIR:
			unit.health -= 0.2
		elif (unit.move_type == gl.MOVE_TYPE.AIR or unit.move_type == gl.MOVE_TYPE.WATER):
			unit.energy -= gl.units[unit.id].energy_per_turn
			if unit.energy <= 0:
				units_to_delete.append(unit)
	for unit in units_to_delete:
		signals.emit_signal("unit_deleted", unit)
	update_all_a_star()

# for player units
func end_unit_action() -> void:
	if !active_unit.joined_this_turn: # subtracted in _on_join_action
		active_unit.energy -= active_unit.current_energy_cost
	active_unit.joined_this_turn = false
	active_unit.current_energy_cost = 0
	active_unit.last_pos = null
	active_unit.end_action()
	clear_active_unit()
	action_menu_open = false
	update_all_a_star()

func disable_input(value: bool) -> void:
	get_tree().get_root().set_disable_input(value)

func _on_UnitMenu_visibility_changed() -> void:
	signals.emit_signal("send_units_to_table", active_team.units)

func _on_StatusInfoMenu_visibility_changed() -> void:
	signals.emit_signal("send_teams_to_table", teams)

func _on_COMenu_visibility_changed() -> void:
	var co_array = []
	for team in teams:
		co_array.append(team.co_resource)
	signals.emit_signal("send_cos_to_menu", co_array)
