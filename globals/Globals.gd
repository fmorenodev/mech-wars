extends Node

var DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
var IND_DIRECTIONS = [Vector2(0, -2), Vector2(1, -1), Vector2(2, 0), Vector2(1, 1),
					Vector2(0, 2), Vector2(-1, 1), Vector2(-2, 0), Vector2(-1, -1)]
var IND_DIRECTIONS_ARTILLERY = IND_DIRECTIONS + [Vector2(0, -3), Vector2(1, -2),
					Vector2(2, -1), Vector2(3, 0), Vector2(2, 1), Vector2(1, 2), 
					Vector2(0, 3), Vector2(-1, 2), Vector2(-2, 1), Vector2(-3, 0),
					Vector2(-2, -1), Vector2(-1, -2)]
var tile_size: int = 24
var map_size: Vector2 = Vector2(14, 11)
var a_star: AStar2D

var units = { UNITS.LIGHT_INFANTRY: 
				{unit_name = 'Light Infantry',
				movement = 4,
				energy = 99,
				move_type = MOVE_TYPE.LIGHT_INF,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 55, UNITS.ARTILLERY: 15},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 1000,
				can_capture = true},
			UNITS.ARTILLERY: 
				{unit_name = 'Artillery',
				movement = 6,
				energy = 99,
				move_type = MOVE_TYPE.ARTILLERY,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 90, UNITS.ARTILLERY: 75},
				atk_type = ATTACK_TYPE.ARTILLERY,
				cost = 6000,
				can_capture = false}
			}
enum UNITS {LIGHT_INFANTRY, ARTILLERY}
enum MOVE_TYPE {LIGHT_INF, ARTILLERY}
enum ATTACK_TYPE {DIRECT, ARTILLERY}
enum TEAM {RED, BLUE}
enum TURN_TYPE {ATTACK, CAPTURE, REPAIR, MOVE}

enum TILES {PLAINS, FOREST, SMALL_MOUNTAIN, MOUNTAIN, WATER}
enum BUILDINGS {RUINS, RUINS_2, FACTORY, AIRPORT, PORT, RESEARCH, POWER_PLANT}

func is_indirect(unit: Unit) -> bool:
	if unit.atk_type == MOVE_TYPE.ARTILLERY:
		return true
	return false

func clamp(grid_position: Vector2) -> Vector2:
	var result := grid_position
	result.x = clamp(result.x, 0, map_size.x - 1.0)
	result.y = clamp(result.y, 0, map_size.y - 1.0)
	return result

# currently unused
func delete_duplicates(array: Array) -> Array:
	var result = []
	for i in range(array.size()):
		var duplicated = false
		for j in range(i+1, array.size()):
			if array[i] == array[j]:
				duplicated = true
				break
		if not duplicated:
			result += [array[i]]
	return result

# only for 2x2 matrix inside a normal array
func delete_duplicates_unordered_matrix(array: Array) -> Array:
	var result = []
	for i in range(array.size()):
		var duplicated = false
		for j in range(i+1, array.size()):
			if array[i][0] == array[j][0] and array[i][1] == array[j][1]:
				duplicated = true
				break
			if array[i][1] == array[j][0] and array[i][0] == array[j][1]:
				duplicated = true
				break
			if array[i][0] == array[j][1] and array[i][1] == array[j][0]:
				duplicated = true
				break
			if array[i][1] == array[j][1] and array[i][0] == array[j][0]:
				duplicated = true
				break
		if not duplicated:
			result += [array[i]]
	return result
