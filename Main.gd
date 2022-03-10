extends Node2D

onready var CursorTileMap: TileMap = $CursorTileMap
onready var SelectionTileMap: TileMap = $SelectionTileMap
onready var TerrainTileMap: TileMap = $TerrainTileMap
onready var PathTileMap: PathTileMap = $PathTileMap
onready var ActionMenu: PopupMenu = $GUI/GUIContainer/ActionMenu

var active_unit: Unit
var walkable_cells := []
var units: Array
var menu_open := false
var targets := []
var selecting_targets := false

func initialize() -> void:
	CursorTileMap.cursor_pos = Vector2.ZERO
	CursorTileMap.set_cellv(CursorTileMap.cursor_pos, 0)
	init_a_star()
	units.clear()

func _ready() -> void:
	var _err = gl.connect("accept_pressed", self, "_on_accept_pressed")
	_err = gl.connect("cancel_pressed", self, "_on_cancel_pressed")
	_err = gl.connect("cursor_moved", self, "_on_cursor_moved")
	_err = gl.connect("move_action", self, "_on_move_action")
	_err = gl.connect("cancel_action", self, "_on_cancel_action")
	_err = gl.connect("attack_action", self, "_on_attack_action")
	_err = gl.connect("target_selected", self, "_on_target_selected")
	_err = gl.connect("unit_deleted", self, "_on_unit_deleted")
	initialize()
	var i = 0
	for child in SelectionTileMap.get_children():
		if i == 0:
			child.initialize(0)
		else:
			child.initialize(1)
		units.append(child)
		if i % 2 == 0:
			child.set_team(gl.TEAM.BLUE)
		else:
			child.set_team(gl.TEAM.RED)
		i += 1

func init_a_star() -> void:
	gl.a_star = AStar2D.new()
	for x in gl.map_size.x:
		for y in gl.map_size.y:
			add_and_connect_point(Vector2(x, y))

func add_and_connect_point(pos: Vector2) -> void:
	var new_id = gl.a_star.get_available_point_id()
	match TerrainTileMap.get_cellv(pos):
		0, 3, 6, 4: # plains or buildings
			gl.a_star.add_point(new_id, pos, 1)
		1: # forest
			gl.a_star.add_point(new_id, pos, 2)
		2, 5: # mountain
			gl.a_star.add_point(new_id, pos, 3)
		7: # water
			gl.a_star.add_point(new_id, pos, 99)
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

func deselect_active_unit() -> void:
	active_unit.is_selected = false
	SelectionTileMap.clear()
	PathTileMap.clear()

func select_unit() -> void:
	active_unit.is_selected = true
	walkable_cells = get_walkable_cells(active_unit)
	for pos in walkable_cells:
		SelectionTileMap.set_cellv(pos, 0)

func clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()

func open_action_menu(menu_options: PoolIntArray, pos: Vector2) -> void:
	ActionMenu.generate_menu(menu_options)
	ActionMenu.rect_position = TerrainTileMap.map_to_world(pos) + Vector2(gl.tile_size, gl.tile_size)
	ActionMenu.show()

func check_targets() -> Array:
	var result := []
	var directions := []
	match active_unit.atk_type:
		gl.ATTACK_TYPE.DIRECT:
			directions = gl.DIRECTIONS
		gl.ATTACK_TYPE.ARTILLERY:
			directions = gl.IND_DIRECTIONS_ARTILLERY
	for direction in directions:
		var coordinates: Vector2 = TerrainTileMap.world_to_map(active_unit.position) + direction
		var unit = is_unit_in_position(coordinates)
		if unit and unit.team != active_unit.team:
			result.append(coordinates)
	return result

func move_active_unit(target_pos: Vector2) -> void:
	
	var unit_blocking = is_unit_in_position(target_pos)
	if (unit_blocking and unit_blocking != active_unit) or not target_pos in walkable_cells: # empty
		return
	
	if PathTileMap.map_to_world(target_pos) == active_unit.position:
		deselect_active_unit()
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
	targets = check_targets()
	
	# build_menu
	var menu_options = []
	if !targets.empty():
		menu_options.append(2) # menu_options.attack
	menu_open = true
	open_action_menu(menu_options, target_pos)

func select_unit_or_building(pos: Vector2) -> void:
	active_unit = is_unit_in_position(pos) if is_unit_in_position(pos) else null
	if active_unit:
		if active_unit.can_move:
			select_unit()
		else:
			active_unit = null
	elif TerrainTileMap.get_cellv(pos) == 4:
		pass # open building menu
	else:
		pass # open status menu

func is_off_borders(pos: Vector2) -> bool:
	return pos.x < Vector2.ZERO.x or pos.x >= gl.map_size.x or pos.y < Vector2.ZERO.y or pos.y >= gl.map_size.y

func is_unit_in_position(pos: Vector2):
	var global_pos = SelectionTileMap.map_to_world(pos)
	for unit in units:
		if unit.position == global_pos:
			return unit
	return false

func _on_accept_pressed(pos: Vector2) -> void:
	if not active_unit:
		select_unit_or_building(pos)
	elif active_unit.is_selected:
		move_active_unit(pos)

func _on_cancel_pressed() -> void:
	if menu_open:
		_on_cancel_action()
	else:
		deselect_active_unit()
		clear_active_unit()

func _on_cursor_moved(target_pos: Vector2) -> void:
	if active_unit and active_unit.is_selected:
		PathTileMap.draw(PathTileMap.world_to_map(active_unit.position), target_pos)

func _on_move_action() -> void:
	active_unit.end_action()
	clear_active_unit()
	menu_open = false

func _on_cancel_action() -> void:
	if active_unit.last_pos:
		active_unit.position = active_unit.last_pos
	targets = []
	select_unit()
	menu_open = false
	if selecting_targets:
		selecting_targets = false

func _on_attack_action() -> void:
	if !targets.empty():
		selecting_targets = true
		CursorTileMap.set_cellv(targets[0], 1)

func _on_target_selected(pos: Vector2) -> void:
	var target_unit: Unit = is_unit_in_position(pos)
	# missing terrain defense bonus
	target_unit.health = target_unit.health - active_unit.dmg_chart[target_unit.id] * (active_unit.health / 100)
	targets = []
	if target_unit and target_unit.atk_type == gl.ATTACK_TYPE.DIRECT and active_unit.atk_type == gl.ATTACK_TYPE.DIRECT:
		active_unit.health = active_unit.health - target_unit.dmg_chart[target_unit.id] * (target_unit.health / 100)
	selecting_targets = false
	active_unit.end_action()
	clear_active_unit()
	menu_open = false

func _on_unit_deleted(unit: Unit) -> void:
	units.remove(units.find(unit))
	unit.queue_free()

func disable_input(value: bool) -> void:
	get_tree().get_root().set_disable_input(value)
