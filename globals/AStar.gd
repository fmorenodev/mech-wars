extends Node

var a_star_maps: Array = [[], []]

onready var Main = get_node('/root/Main')

func init_a_star() -> void: 
	for team in Main.teams:
		for i in gl.MOVE_TYPE.size():
			var a_star = AStar2D.new()
			for x in gl.map_size.x:
				for y in gl.map_size.y:
					add_and_connect_point(a_star, Vector2(x, y), team.color)
			a_star_maps[team.color].append(a_star)

func get_a_star_type(a_star: AStar2D, team: int) -> int:
	for i in a_star_maps[team].size():
		if a_star == a_star_maps[team][i]:
			return i
	return -1

func update_point(a_star: AStar2D, id: int, pos: Vector2, team: int) -> void:
	var move_type = get_a_star_type(a_star, team)
	if move_type == -1:
		a_star.add_point(id, pos, 1)
	else:
		match Main.TerrainTileMap.get_cellv(pos):
			gl.TERRAIN.PLAINS:
				match move_type:
					gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE, gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.FOREST:
				match move_type:
					gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE:
						a_star.add_point(id, pos, 2)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.SMALL_MOUNTAIN, gl.TERRAIN.MOUNTAIN:
				match move_type:
					gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.INFANTRY:
						a_star.add_point(id, pos, 3)
					gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE, gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.WATER:
				match move_type:
					gl.MOVE_TYPE.AIR, gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.ROAD:
				match move_type:
					gl.MOVE_TYPE.AIR, gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.RIVER:
				match move_type:
					gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.INFANTRY:
						a_star.add_point(id, pos, 2)
					gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE, gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.WASTELAND:
				match move_type:
					gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.INFANTRY:
						a_star.add_point(id, pos, 2)
					gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE:
						a_star.add_point(id, pos, 3)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.REEF:
				match move_type:
					gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 2)
					gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE:
						a_star.add_point(id, pos, 99)
			gl.TERRAIN.SPECIAL:
				match move_type:
					gl.MOVE_TYPE.INFANTRY, gl.MOVE_TYPE.LIGHT_VEHICLE, gl.MOVE_TYPE.HEAVY_VEHICLE, gl.MOVE_TYPE.AIR:
						a_star.add_point(id, pos, 1)
					gl.MOVE_TYPE.WATER:
						a_star.add_point(id, pos, 99)

func add_and_connect_point(a_star: AStar2D, pos: Vector2, team: int) -> void:
	var new_id = a_star.get_available_point_id()
	update_point(a_star, new_id, pos, team)
	var points_to_connect = []
	for direction in gl.DIRECTIONS:
		for point in a_star.get_points():
			if a_star.get_point_position(point) == pos + direction:
				points_to_connect.append(a_star.get_closest_point(pos + direction))
	for point in points_to_connect:
		a_star.connect_points(new_id, point)

func get_path_weight(a_star: int, from_id: int, to_id: int, team: int, to_enemy: bool = false) -> int:
	var id_point_array: Array = a_star_maps[team][a_star].get_id_path(from_id, to_id)
	id_point_array.pop_front()
	if to_enemy:
		id_point_array.pop_back()
	var result = 0
	for id in id_point_array:
		result += a_star_maps[team][a_star].get_point_weight_scale(id)
	return result

func flood_fill(a_star_num: int, start_pos: Vector2, max_distance: int, team: int) -> Array:
	var result := []
	var stack := [start_pos]
	var a_star = a_star_maps[team][a_star_num]
	var a_star_start_point = a_star.get_closest_point(start_pos)
	while not stack.empty():
		var cur_pos = stack.pop_back()

		if gl.is_off_borders(cur_pos):
			continue
		if cur_pos in result:
			continue

		var a_star_cur_point = a_star.get_closest_point(cur_pos)

		var distance = get_path_weight(a_star_num, a_star_start_point, a_star_cur_point, team)
		if distance > max_distance:
			continue

		result.append(cur_pos)
		for direction in gl.DIRECTIONS:
			var coordinates: Vector2 = cur_pos + direction
			if coordinates in result:
				continue

			stack.append(coordinates)
	return result

func get_partial_path(unit: Unit, from_id: int, to_id: int) -> Array:
	var a_star = a_star_maps[unit.team][unit.move_type]
	var path = a_star.get_id_path(from_id, to_id)
	var remaining_movement = unit.movement
	var walkable_path = [a_star.get_point_position(path[0])]
	path.remove(0)
	for point_id in path:
		var weight = a_star.get_point_weight_scale(point_id)
		remaining_movement -= weight
		if remaining_movement < 0:
			break
		else:
			walkable_path.append(a_star.get_point_position(path[0]))
			path.remove(0)
	walkable_path = ends_path_in_unit(walkable_path)
	return walkable_path

func ends_path_in_unit(point_path: Array) -> Array:
	for i in range(point_path.size() - 1, -1, -1):
		if Main.is_unit_in_position(point_path[i]):
			point_path.remove(i)
		else:
			return point_path
	return point_path
