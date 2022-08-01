extends Node2D

onready var CursorTileMap: TileMap = $CursorTileMap
onready var SelectionTileMap: TileMap = $SelectionTileMap
onready var TerrainTileMap: TileMap = $TerrainTileMap
onready var BuildingsTileMap: TileMap = $BuildingsTileMap
onready var PathTileMap: PathTileMap = $PathTileMap
onready var ActionMenu: PopupMenu = $GUI/GUIContainer/ActionMenu
onready var StatusMenu: PopupMenu = $GUI/GUIContainer/StatusMenu
onready var BuildingMenu: PopupMenu = $GUI/GUIContainer/BuildingMenu

const Team = preload("res://Team.gd")
const UnitScene = preload("res://Unit.tscn")

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

func _ready() -> void:
	var _err = signals.connect("accept_pressed", self, "_on_accept_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	_err = signals.connect("cursor_moved", self, "_on_cursor_moved")
	_err = signals.connect("move_action", self, "_on_move_action")
	_err = signals.connect("cancel_action", self, "_on_cancel_action")
	_err = signals.connect("attack_action", self, "_on_attack_action")
	_err = signals.connect("capture_action", self, "_on_capture_action")
	_err = signals.connect("target_selected", self, "_on_target_selected")
	_err = signals.connect("unit_added", self, "_on_unit_added")
	_err = signals.connect("unit_deleted", self, "_on_unit_deleted")
	_err = signals.connect("turn_ended", self, "_on_turn_ended")
	initialize([Team.new(gl.TEAM.RED, true), Team.new(gl.TEAM.BLUE, false)])
	var i = 0
	for child in SelectionTileMap.get_children():
		if i % 2 == 0:
			add_unit_data(child, randi() % 2, gl.TEAM.RED)
		else:
			add_unit_data(child, randi() % 2, gl.TEAM.BLUE)
		i = i + 1
	for child in BuildingsTileMap.get_children():
		add_building_data(child, randi() % gl.BUILDINGS.size(), -1)
	init_a_star()
	start_turn()

func create_unit(unit_id: int, team: int, position: Vector2) -> void:
	var new_unit = UnitScene.instance()
	SelectionTileMap.add_child(new_unit)
	new_unit.position = position
	new_unit.end_action()
	add_unit_data(new_unit, unit_id, team)

func add_unit_data(unit: Unit, unit_id: int, team: int) -> void:
	unit.initialize(unit_id)
	units.append(unit)
	teams[team].add_unit(unit)

func add_building_data(building: Building, type: int, team: int, funds: int = 1000, available_units: PoolIntArray = []):
	building.initialize(type, team, funds, available_units)
	buildings.append(building)
	if (team >= 0):
		teams[team].add_building(building)

##############
# A* FUNCTIONS
##############

func init_a_star() -> void:
	gl.a_star = AStar2D.new()
	for x in gl.map_size.x:
		for y in gl.map_size.y:
			add_and_connect_point(Vector2(x, y))

func update_a_star() -> void:
	for unit in units:
		if unit.team != active_team.color:
			var pos = SelectionTileMap.world_to_map(unit.position)
			var point = gl.a_star.get_closest_point(pos)
			gl.a_star.add_point(point, pos, 99)
	for x in gl.map_size.x:
		for y in gl.map_size.y:
			var pos = Vector2(x, y)
			if is_unit_in_position(pos):
				pass
			else:
				update_point(gl.a_star.get_closest_point(pos), pos)

func update_point(id: int, pos: Vector2) -> void:
	match TerrainTileMap.get_cellv(pos):
		0: # plains
			gl.a_star.add_point(id, pos, 1)
		1: # forest
			gl.a_star.add_point(id, pos, 2)
		2, 3: # mountain
			gl.a_star.add_point(id, pos, 3)
		4: # water
			gl.a_star.add_point(id, pos, 99)

func add_and_connect_point(pos: Vector2) -> void:
	var new_id = gl.a_star.get_available_point_id()
	update_point(new_id, pos)
	var points_to_connect = []
	for direction in gl.DIRECTIONS:
		for point in gl.a_star.get_points():
			if gl.a_star.get_point_position(point) == pos + direction:
				points_to_connect.append(gl.a_star.get_closest_point(pos + direction))
	for point in points_to_connect:
		gl.a_star.connect_points(new_id, point)

func get_path_weight(from_id: int, to_id: int) -> int:
	var id_point_array: Array = gl.a_star.get_id_path(from_id, to_id)
	id_point_array.pop_front()
	var result = 0
	for id in id_point_array:
		result += gl.a_star.get_point_weight_scale(id)
	return result

func flood_fill(start_pos: Vector2, max_distance: int) -> Array:
	var result := []
	var stack := [start_pos]
	var a_star_start_point = gl.a_star.get_closest_point(start_pos)
	while not stack.empty():
		var cur_pos = stack.pop_back()

		if is_off_borders(cur_pos):
			continue
		if cur_pos in result:
			continue

		var a_star_cur_point = gl.a_star.get_closest_point(cur_pos)

		var distance = get_path_weight(a_star_start_point, a_star_cur_point)
		if distance > max_distance:
			continue

		result.append(cur_pos)
		for direction in gl.DIRECTIONS:
			var coordinates: Vector2 = cur_pos + direction
			if coordinates in result:
				continue

			stack.append(coordinates)
	return result

func get_walkable_cells(unit: Unit) -> Array:
	return flood_fill(TerrainTileMap.world_to_map(unit.position), unit.movement)

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
	for direction in directions:
		var coordinates: Vector2 = TerrainTileMap.world_to_map(pos) + direction
		var target_unit = is_unit_in_position(coordinates)
		if all_possible or (target_unit and target_unit.team != unit.team):
			result.append(coordinates)
	return result

func check_all_targets(unit: Unit) -> Array:
	if gl.is_indirect(unit):
		return check_targets(unit, unit.position)
	else:
		var wk_cells = get_walkable_cells(unit)
		for i in range(wk_cells.size() - 1, -1, -1):
			if is_unit_in_position(wk_cells[i]):
				wk_cells.remove(i)
		var th_cells: Array = []
		for cell in wk_cells:
			var tgs = check_targets(unit, SelectionTileMap.map_to_world(cell))
			th_cells = th_cells + tgs
		th_cells = gl.delete_duplicates(th_cells)
		return th_cells

func threatened_cells(unit: Unit) -> Array:
	var th_cells := []
	if gl.is_indirect(unit):
		for dir in gl.IND_DIRECTIONS_ARTILLERY:
			th_cells.append(dir + SelectionTileMap.world_to_map(unit.position))
	else:
		var wk_cells = get_walkable_cells(unit)
		for i in range(wk_cells.size() - 1, -1, -1):
			if is_unit_in_position(wk_cells[i]):
				wk_cells.remove(i)
		for cell in wk_cells:
			var tgs = check_targets(unit, SelectionTileMap.map_to_world(cell), true)
			th_cells = th_cells + tgs
		th_cells = th_cells + wk_cells
		th_cells = gl.delete_duplicates(th_cells)
	return th_cells

func check_buildings(unit: Unit, owned: bool) -> Array:
	var buildings_result := []
	var wk_cells = get_walkable_cells(unit)
	for i in range(wk_cells.size() - 1, -1, -1):
		if is_unit_in_position(wk_cells[i]):
			wk_cells.remove(i)
	for cell in wk_cells:
		var building = is_building_in_position(unit.position)
		if building and (!owned and building.team != unit.team) and (owned and building.team == unit.team):
			buildings_result.append(building)
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
			if active_unit.team != active_team.color:
				var th_cells = threatened_cells(selected_entity)
				for pos in th_cells:
					SelectionTileMap.set_cellv(pos, 1)
			active_unit = null
	elif selected_entity is Building and selected_entity.team == active_team.color:
		open_building_menu(selected_entity)
	else:
		open_status_menu()

func move_active_unit(target_pos: Vector2) -> void:
	# TODO: if unit_blocking is a unit and the active_unit can attack it, do it
	var unit_blocking = is_unit_in_position(target_pos)
	if (unit_blocking and unit_blocking != active_unit) or not target_pos in walkable_cells: # empty
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
		disable_input(false)
		active_unit.position = path_world_coords.back()
	
	# check for attack targets
	if active_unit.atk_type == gl.ATTACK_TYPE.DIRECT:
		targets = check_targets(active_unit, active_unit.position)
	
	# build action menu
	var menu_options = []
	if !targets.empty():
		menu_options.append(2) # menu_options.attack
	var building = is_building_in_position(target_pos)
	if building and active_unit.id == gl.UNITS.LIGHT_INFANTRY and building.team != active_team.color: # TODO: add other inf types
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
	BuildingMenu.generate_menu(building.available_units, active_team.funds, active_team.color, building.position)
	BuildingMenu.show()
	StatusMenu.hide()

func open_status_menu() -> void:
	StatusMenu.show()
	BuildingMenu.hide()

func close_menus() -> void:
	StatusMenu.hide()
	BuildingMenu.hide()

##########################
# TILE CHECKER FUNCTIONS #
##########################

func is_off_borders(pos: Vector2) -> bool:
	return pos.x < Vector2.ZERO.x or pos.x >= gl.map_size.x or pos.y < Vector2.ZERO.y or pos.y >= gl.map_size.y

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
		PathTileMap.draw(PathTileMap.world_to_map(active_unit.position), target_pos)

func _on_move_action() -> void:
	end_unit_action()

func _on_cancel_action() -> void:
	if active_unit.last_pos:
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
		CursorTileMap.set_cellv(targets[0], 1)

func _on_capture_action() -> void:
	active_unit.capture()
	if active_unit.capture_points >= 20:
		active_unit.capture_points = 0
		var building = is_building_in_position(SelectionTileMap.world_to_map(active_unit.position))
		building.capture(active_team.color)
		active_team.add_building(building)
	end_unit_action()

func _on_target_selected(pos: Vector2) -> void:
	var target_unit: Unit = is_unit_in_position(pos)
	target_unit.health -= calc_damage(active_unit, target_unit)
	targets = []
	if target_unit and target_unit.atk_type == gl.ATTACK_TYPE.DIRECT and active_unit.atk_type == gl.ATTACK_TYPE.DIRECT:
		active_unit.health -= calc_damage(target_unit, active_unit)
	selecting_targets = false
	active_unit.end_action()
	clear_active_unit()
	action_menu_open = false

func _on_unit_added(unit_id: int, team: int, position: Vector2) -> void:
	create_unit(unit_id, team, position)
	teams[team].funds -= gl.units[unit_id].cost

func _on_unit_deleted(unit: Unit) -> void:
	units.erase(unit)
	teams[unit.team].units.erase(unit)
	unit.queue_free()

func _on_turn_ended() -> void:
	for unit in active_team.units:
		unit.end_turn()
	current_index += 1
	if current_index > teams.size() - 1:
		current_index = 0
	active_team = teams[current_index]
	start_turn()

#################
# AUX FUNCTIONS #
#################

# TODO missing terrain defense bonus and co bonus
func calc_damage(attacker: Unit, target: Unit, add_random: bool = true) -> int:
	var result = (attacker.dmg_chart[target.id] * (attacker.health / 10.0))
	if add_random:
		result += (randi() % 11 * attacker.health / 10.0) / 10.0
	return int(result)

# TODO missing attribute to know if target can retaliate against active unit
func calc_retaliation_damage(attacker: Unit, target: Unit, dmg_suffered: int, add_random: bool = true) -> int:
	if target and target.atk_type == gl.ATTACK_TYPE.DIRECT and attacker.atk_type == gl.ATTACK_TYPE.DIRECT:
		var result = (attacker.dmg_chart[target.id] * (attacker.health - dmg_suffered / 10.0) + (randi() % 11 * (attacker.health - dmg_suffered) / 10.0)) / 10.0
		if add_random:
			result += (randi() % 11 * attacker.health - dmg_suffered / 10.0) / 10.0
		return result
	else:
		return 0

func calc_dmg_value(attacker: Unit, target: Unit) -> int:
	if target and target.atk_type == gl.ATTACK_TYPE.DIRECT and attacker.atk_type == gl.ATTACK_TYPE.DIRECT:
		attacker.health -= calc_damage(attacker, target)
	var dmg = calc_damage(attacker, target, false)
	var retaliation_dmg = calc_retaliation_damage(attacker, target, dmg, false)
	var value = dmg * (target.cost / 1000.0) - retaliation_dmg * (attacker.cost / 1000.0)
	return value

func start_turn() -> void:
	for building in active_team.buildings:
		active_team.funds += 1000
	for unit in active_team.units:
		unit.activate()
		for building in active_team.buildings:
			if unit.position == building.position:
				var damage = 10 - unit.health
				if damage > 0:
					var repair_cost = unit.cost * min(0.2, damage / 10)
					if repair_cost <= active_team.funds:
						unit.health += min(damage, 2)
						active_team.funds -= repair_cost
	update_a_star()
	if !active_team.is_player:
		signals.emit_signal("start_ai_turn", active_team)

func end_unit_action() -> void:
	active_unit.last_pos = active_unit.position
	active_unit.end_action()
	clear_active_unit()
	action_menu_open = false
	update_a_star()

func disable_input(value: bool) -> void:
	get_tree().get_root().set_disable_input(value)
