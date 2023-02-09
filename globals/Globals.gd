extends Node

var DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
var IND_DIRECTIONS = [Vector2(0, -2), Vector2(1, -1), Vector2(2, 0), Vector2(1, 1),
					Vector2(0, 2), Vector2(-1, 1), Vector2(-2, 0), Vector2(-1, -1)]
var IND_DIRECTIONS_ARTILLERY = IND_DIRECTIONS + [Vector2(0, -3), Vector2(1, -2),
					Vector2(2, -1), Vector2(3, 0), Vector2(2, 1), Vector2(1, 2), 
					Vector2(0, 3), Vector2(-1, 2), Vector2(-2, 1), Vector2(-3, 0),
					Vector2(-2, -1), Vector2(-1, -2)]
var IND_DIRECTIONS_HEAVY_ARTILLERY = [Vector2(0, -5), Vector2(1, -4), Vector2(2, -3),
					Vector2(3, -2), Vector2(4, -1), Vector2(5, 0), Vector2(4, 1),
					Vector2(3, 2), Vector2(2, 3), Vector2(1, 4), Vector2(0, 5),
					Vector2(-1, 4), Vector2(-2, 3), Vector2(-3, 2), Vector2(-4, 1),
					Vector2(-5, 0), Vector2(-4, -1), Vector2(-3, -2), Vector2(-2, -3),
					Vector2(-1, -4),
					Vector2(0, -4), Vector2(1, -3), Vector2(2, -2), Vector2(3, -1),
					Vector2(4, 0), Vector2(3, 1), Vector2(2, 2), Vector2(1, 3),
					Vector2(0, 4), Vector2(-1, 3), Vector2(-2, 2), Vector2(-3, 1),
					Vector2(-4, 0), Vector2(-3, -1), Vector2(-2, -2), Vector2(-1, -3),
					Vector2(0, -3), Vector2(1, -2), Vector2(2, -1), Vector2(3, 0),
					Vector2(2, 1), Vector2(1, 2), Vector2(0, 3), Vector2(-1, 2),
					Vector2(-2, 1), Vector2(-3, 0), Vector2(-2, -1), Vector2(-1, -2)]
var tile_size: int = 24
var map_size: Vector2 = Vector2(19, 12)

var units = { UNITS.LIGHT_INFANTRY: 
				{unit_name = 'Light Infantry',
				movement = 4,
				energy = 99,
				move_type = MOVE_TYPE.INFANTRY,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 55, UNITS.HEAVY_INFANTRY: 45,
					UNITS.RECON: 12, UNITS.LIGHT_TANK: 5, UNITS.MEDIUM_TANK: 1,
					UNITS.ARTILLERY: 15, UNITS.HEAVY_ARTILLERY: 25, UNITS.ANTI_AIR: 5,
					UNITS.DRONE: 7, UNITS.BATTLESHIP: 0},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 1500,
				can_capture = true},
			UNITS.HEAVY_INFANTRY: 
				{unit_name = 'Heavy Infantry',
				movement = 3,
				energy = 99,
				move_type = MOVE_TYPE.INFANTRY,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 65, UNITS.HEAVY_INFANTRY: 55,
					UNITS.RECON: 85, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 15,
					UNITS.ARTILLERY: 70, UNITS.HEAVY_ARTILLERY: 85, UNITS.ANTI_AIR: 65,
					UNITS.DRONE: 9, UNITS.BATTLESHIP: 0},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 3000,
				can_capture = true},
			UNITS.RECON: 
				{unit_name = 'Recon Mech',
				movement = 7,
				energy = 99,
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 70, UNITS.HEAVY_INFANTRY: 65,
					UNITS.RECON: 35, UNITS.LIGHT_TANK: 6, UNITS.MEDIUM_TANK: 1,
					UNITS.ARTILLERY: 45, UNITS.HEAVY_ARTILLERY: 55, UNITS.ANTI_AIR: 4,
					UNITS.DRONE: 9, UNITS.BATTLESHIP: 0},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 5000,
				can_capture = false},
			UNITS.LIGHT_TANK:
				{unit_name = 'Tank',
				movement = 7,
				energy = 99,
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 75, UNITS.HEAVY_INFANTRY: 70,
					UNITS.RECON: 85, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 15,
					UNITS.ARTILLERY: 70, UNITS.HEAVY_ARTILLERY: 85, UNITS.ANTI_AIR: 65,
					UNITS.DRONE: 9, UNITS.BATTLESHIP: 1},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 7000,
				can_capture = false},
			UNITS.MEDIUM_TANK:
				{unit_name = 'Medium Tank',
				movement = 6,
				energy = 99,
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 105, UNITS.HEAVY_INFANTRY: 95,
					UNITS.RECON: 105, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 105, UNITS.HEAVY_ARTILLERY: 105, UNITS.ANTI_AIR: 105,
					UNITS.DRONE: 12, UNITS.BATTLESHIP: 10},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 15000,
				can_capture = false},
			UNITS.ARTILLERY:
				{unit_name = 'Artillery',
				movement = 6,
				energy = 99,
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 90, UNITS.HEAVY_INFANTRY: 85,
					UNITS.RECON: 80, UNITS.LIGHT_TANK: 70, UNITS.MEDIUM_TANK: 45,
					UNITS.ARTILLERY: 75, UNITS.HEAVY_ARTILLERY: 80, UNITS.ANTI_AIR: 75,
					UNITS.DRONE: 0, UNITS.BATTLESHIP: 40},
				atk_type = ATTACK_TYPE.ARTILLERY,
				cost = 6000,
				can_capture = false},
			UNITS.HEAVY_ARTILLERY:
				{unit_name = 'Heavy Artillery',
				movement = 5,
				energy = 99,
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 95, UNITS.HEAVY_INFANTRY: 90,
					UNITS.RECON: 90, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 80, UNITS.HEAVY_ARTILLERY: 85, UNITS.ANTI_AIR: 85,
					UNITS.DRONE: 0, UNITS.BATTLESHIP: 55},
				atk_type = ATTACK_TYPE.HEAVY_ARTILLERY,
				cost = 15000,
				can_capture = false},
			UNITS.ANTI_AIR:
				{unit_name = 'Anti Air Mech',
				movement = 7,
				energy = 99,
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 105, UNITS.HEAVY_INFANTRY: 105,
					UNITS.RECON: 60, UNITS.LIGHT_TANK: 25, UNITS.MEDIUM_TANK: 10,
					UNITS.ARTILLERY: 50, UNITS.HEAVY_ARTILLERY: 45, UNITS.ANTI_AIR: 45,
					UNITS.DRONE: 120, UNITS.BATTLESHIP: 0},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 8000,
				can_capture = false},
			UNITS.DRONE:
				{unit_name = 'Drone',
				movement = 7,
				energy = 99,
				move_type = MOVE_TYPE.AIR,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 75, UNITS.HEAVY_INFANTRY: 75,
					UNITS.RECON: 5, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 25,
					UNITS.ARTILLERY: 65, UNITS.HEAVY_ARTILLERY: 65, UNITS.ANTI_AIR: 25,
					UNITS.DRONE: 65, UNITS.BATTLESHIP: 25},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 9000,
				can_capture = false},
			UNITS.BATTLESHIP:
				{unit_name = 'Battleship',
				movement = 6,
				energy = 99,
				move_type = MOVE_TYPE.WATER,
				dmg_chart = {UNITS.LIGHT_INFANTRY: 95, UNITS.HEAVY_INFANTRY: 90,
					UNITS.RECON: 90, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 80, UNITS.HEAVY_ARTILLERY: 85, UNITS.ANTI_AIR: 85,
					UNITS.DRONE: 0, UNITS.BATTLESHIP: 50},
				atk_type = ATTACK_TYPE.HEAVY_ARTILLERY,
				cost = 15000,
				can_capture = false},
			}

enum UNITS {LIGHT_INFANTRY, HEAVY_INFANTRY, RECON, LIGHT_TANK, MEDIUM_TANK, ARTILLERY, HEAVY_ARTILLERY, ANTI_AIR, DRONE, BATTLESHIP }
enum MOVE_TYPE {INFANTRY, LIGHT_VEHICLE, HEAVY_VEHICLE, AIR, WATER}
enum ATTACK_TYPE {DIRECT, ARTILLERY, HEAVY_ARTILLERY}
enum TEAM {RED, BLUE}
enum TURN_TYPE {ATTACK, CAPTURE, REPAIR, MOVE}

enum TERRAIN {PLAINS, FOREST, SMALL_MOUNTAIN, MOUNTAIN, WATER, ROAD, RIVER, WASTELAND, REEF, ENERGY_RELAY, SCRAPYARD, BEACH}
enum BUILDINGS {RUINS, RUINS_2, FACTORY, AIRPORT, PORT, RESEARCH, POWER_PLANT}

func is_indirect(unit: Unit) -> bool:
	if unit.atk_type == ATTACK_TYPE.ARTILLERY or unit.atk_type == ATTACK_TYPE.HEAVY_ARTILLERY:
		return true
	return false

func clamp(grid_position: Vector2) -> Vector2:
	var result := grid_position
	result.x = clamp(result.x, 0, map_size.x - 1.0)
	result.y = clamp(result.y, 0, map_size.y - 1.0)
	return result

func is_off_borders(pos: Vector2) -> bool:
	return pos.x < Vector2.ZERO.x or pos.x >= gl.map_size.x or pos.y < Vector2.ZERO.y or pos.y >= gl.map_size.y

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
			if array[i][0] == array[j][0] and array[i][1] == array[j][1] or \
			array[i][1] == array[j][0] and array[i][0] == array[j][1] or \
			array[i][0] == array[j][1] and array[i][1] == array[j][0] or \
			array[i][1] == array[j][1] and array[i][0] == array[j][0]:
				duplicated = true
				break
		if not duplicated:
			result += [array[i]]
	return result
