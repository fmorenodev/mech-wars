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
var map_size: Vector2

var units = { UNITS.LIGHT_INFANTRY:
				{unit_name = tr('LIGHT_INF'),
				desc = tr('LIGHT_INF_DESC'),
				movement = 4,
				energy = 99,
				ammo = -1,
				weapon_1 = tr('NONE'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK, 
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.INFANTRY,
				w1_dmg_chart = {},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 55, UNITS.HEAVY_INFANTRY: 45,
					UNITS.FLYING_INFANTRY: 45, UNITS.RECON: 12, UNITS.LIGHT_TANK: 5,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 15, UNITS.HEAVY_ARTILLERY: 25,
					UNITS.ARC_TOWER: 15, UNITS.ANTI_AIR: 5, UNITS.ROCKET: 25,
					UNITS.DRONE: 7},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 1500,
				point_cost = 1,
				can_capture = true},
			UNITS.HEAVY_INFANTRY: 
				{unit_name = tr('HEAVY_INF'),
				desc = tr('HEAVY_INF_DESC'),
				movement = 3,
				energy = 70,
				ammo = 3,
				weapon_1 = tr('CANNON'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY, UNITS.ARC_TOWER,
					UNITS.ANTI_AIR, UNITS.ROCKET],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK, 
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.INFANTRY,
				w1_dmg_chart = {UNITS.RECON: 85, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 15,
					UNITS.ARTILLERY: 70, UNITS.HEAVY_ARTILLERY: 85, UNITS.ARC_TOWER: 70,
					UNITS.ANTI_AIR: 65, UNITS.ROCKET: 85},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 65, UNITS.HEAVY_INFANTRY: 55,
					UNITS.FLYING_INFANTRY: 55, UNITS.RECON: 18, UNITS.LIGHT_TANK: 6,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 25, UNITS.HEAVY_ARTILLERY: 35,
					UNITS.ARC_TOWER: 25, UNITS.ANTI_AIR: 6, UNITS.ROCKET: 35,
					UNITS.DRONE: 9},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 3000,
				point_cost = 1,
				can_capture = true},
			UNITS.FLYING_INFANTRY:
				{unit_name = tr('FLYING_INF'),
				desc = tr('FLYING_INF_DESC'),
				movement = 4,
				energy = 50,
				energy_per_turn = 2,
				ammo = -1,
				weapon_1 = tr('NONE'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.AIR,
				w1_dmg_chart = {},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 65, UNITS.HEAVY_INFANTRY: 55,
					UNITS.FLYING_INFANTRY: 55, UNITS.RECON: 18, UNITS.LIGHT_TANK: 6,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 25, UNITS.HEAVY_ARTILLERY: 35,
					UNITS.ARC_TOWER: 25, UNITS.ANTI_AIR: 6, UNITS.ROCKET: 35,
					UNITS.DRONE: 20},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 5500,
				point_cost = 2,
				can_capture = true},
			UNITS.RECON: 
				{unit_name = tr('RECON'),
				desc = tr('RECON_DESC'),
				movement = 7,
				energy = 80,
				ammo = -1,
				weapon_1 = tr('NONE'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				w1_dmg_chart = {},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 70, UNITS.HEAVY_INFANTRY: 65,
					UNITS.FLYING_INFANTRY: 65, UNITS.RECON: 35, UNITS.LIGHT_TANK: 6,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 45, UNITS.HEAVY_ARTILLERY: 55,
					UNITS.ARC_TOWER: 45, UNITS.ANTI_AIR: 4, UNITS.ROCKET: 55,
					UNITS.DRONE: 9},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 5000,
				point_cost = 1,
				can_capture = false},
			UNITS.LIGHT_TANK:
				{unit_name = tr('TANK'),
				desc = tr('TANK_DESC'),
				movement = 7,
				energy = 70,
				ammo = 9,
				weapon_1 = tr('CANNON'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY, UNITS.ARC_TOWER,
					UNITS.ANTI_AIR, UNITS.ROCKET, UNITS.BATTLESHIP],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				w1_dmg_chart = {UNITS.RECON: 85, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 15,
					UNITS.ARTILLERY: 70, UNITS.HEAVY_ARTILLERY: 85, UNITS.ARC_TOWER: 70,
					UNITS.ANTI_AIR: 65, UNITS.ROCKET: 85, UNITS.BATTLESHIP: 1},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 75, UNITS.HEAVY_INFANTRY: 70,
					UNITS.FLYING_INFANTRY: 70, UNITS.RECON: 40, UNITS.LIGHT_TANK: 6,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 45, UNITS.HEAVY_ARTILLERY: 55,
					UNITS.ARC_TOWER: 45, UNITS.ANTI_AIR: 5, UNITS.ROCKET: 55,
					UNITS.DRONE: 9},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 7000,
				point_cost = 3,
				can_capture = false},
			UNITS.MEDIUM_TANK:
				{unit_name = tr('MEDIUM_TANK'),
				desc = tr('MEDIUM_TANK_DESC'),
				movement = 6,
				energy = 60,
				ammo = 10,
				weapon_1 = tr('MEDIUM_CANNON'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY, UNITS.ARC_TOWER,
					UNITS.ANTI_AIR, UNITS.ROCKET, UNITS.BATTLESHIP],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				w1_dmg_chart = {UNITS.RECON: 105, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 105, UNITS.HEAVY_ARTILLERY: 105, UNITS.ARC_TOWER: 105,
					UNITS.ANTI_AIR: 105, UNITS.ROCKET: 105, UNITS.BATTLESHIP: 10},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 105, UNITS.HEAVY_INFANTRY: 95,
					UNITS.FLYING_INFANTRY: 95, UNITS.RECON: 45, UNITS.LIGHT_TANK: 8,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 45, UNITS.HEAVY_ARTILLERY: 55,
					UNITS.ARC_TOWER: 45, UNITS.ANTI_AIR: 7, UNITS.ROCKET: 55,
					UNITS.DRONE: 12},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 15500,
				point_cost = 5,
				can_capture = false},
			UNITS.ARTILLERY:
				{unit_name = tr('ARTILLERY'),
				desc = tr('ARTILLERY_DESC'),
				movement = 6,
				energy = 50,
				ammo = 9,
				weapon_1 = tr('ARTILLERY_CANNON'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY, 
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.BATTLESHIP],
				w2_can_attack = [],
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 90, UNITS.HEAVY_INFANTRY: 85,
					UNITS.RECON: 80, UNITS.LIGHT_TANK: 70, UNITS.MEDIUM_TANK: 45,
					UNITS.ARTILLERY: 75, UNITS.HEAVY_ARTILLERY: 80,
					UNITS.ARC_TOWER: 75, UNITS.ANTI_AIR: 75, UNITS.ROCKET: 80,
					UNITS.BATTLESHIP: 40},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.ARTILLERY,
				cost = 6000,
				point_cost = 3,
				can_capture = false},
			UNITS.HEAVY_ARTILLERY:
				{unit_name = tr('HEAVY_ARTILLERY'),
				desc = tr('HEAVY_ARTILLERY_DESC'),
				movement = 5,
				energy = 50,
				ammo = 6,
				weapon_1 = tr('ENERGY_CANNON'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.BATTLESHIP],
				w2_can_attack = [],
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 95, UNITS.HEAVY_INFANTRY: 90,
					UNITS.RECON: 90, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 80, UNITS.HEAVY_ARTILLERY: 85, 
					UNITS.ARC_TOWER: 80, UNITS.ANTI_AIR: 85, UNITS.ROCKET: 85,
					UNITS.BATTLESHIP: 55},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.HEAVY_ARTILLERY,
				cost = 15000,
				point_cost = 5,
				can_capture = false},
			UNITS.ARC_TOWER:
				{unit_name = tr('ARC_TOWER'),
				desc = tr('ARC_TOWER_DESC'),
				movement = 5,
				energy = 50,
				ammo = 4,
				weapon_1 = tr('LIGHTNING_ARC'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.BATTLESHIP],
				w2_can_attack = [],
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 60, UNITS.HEAVY_INFANTRY: 60,
					UNITS.RECON: 30, UNITS.LIGHT_TANK: 30, UNITS.MEDIUM_TANK: 30,
					UNITS.ARTILLERY: 30, UNITS.HEAVY_ARTILLERY: 30, 
					UNITS.ARC_TOWER: 30, UNITS.ANTI_AIR: 30, UNITS.ROCKET: 30,
					UNITS.BATTLESHIP: 30},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.ARTILLERY,
				cost = 10000,
				point_cost = 5,
				can_capture = false},
			UNITS.ANTI_AIR:
				{unit_name = tr('ANTI_AIR'),
				desc = tr('ANTI_AIR_DESC'),
				movement = 7,
				energy = 60,
				ammo = 14,
				weapon_1 = tr('FLAK_CANNON'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				w2_can_attack = [],
				move_type = MOVE_TYPE.LIGHT_VEHICLE,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 105, UNITS.HEAVY_INFANTRY: 105,
					UNITS.FLYING_INFANTRY: 105, UNITS.RECON: 60, UNITS.LIGHT_TANK: 25,
					UNITS.MEDIUM_TANK: 10, UNITS.ARTILLERY: 50, UNITS.HEAVY_ARTILLERY: 55,
					UNITS.ARC_TOWER: 50, UNITS.ANTI_AIR: 45, UNITS.ROCKET: 55,
					UNITS.DRONE: 120},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 8000,
				point_cost = 3,
				can_capture = false},
			UNITS.ROCKET:
				{unit_name = tr('ROCKET'),
				desc = tr('ROCKET_DESC'),
				movement = 5,
				energy = 50,
				ammo = 5,
				weapon_1 = tr('GTA_MISSILE'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.FLYING_INFANTRY, UNITS.DRONE, UNITS.ANGEL,
					UNITS.SKY_FORTRESS],
				w2_can_attack = [],
				move_type = MOVE_TYPE.HEAVY_VEHICLE,
				w1_dmg_chart = {UNITS.FLYING_INFANTRY: 150, UNITS.DRONE: 120,
					UNITS.ANGEL: 100, UNITS.SKY_FORTRESS: 100},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.HEAVY_ARTILLERY,
				cost = 12000,
				point_cost = 5,
				can_capture = false},
			UNITS.DRONE:
				{unit_name = tr('DRONE'),
				desc = tr('DRONE_DESC'),
				movement = 7,
				energy = 80,
				energy_per_turn = 2,
				ammo = 6,
				weapon_1 = tr('ATG_MISSILE'),
				weapon_2 = tr('LASER_GUN'),
				w1_can_attack = [UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.BATTLESHIP],
				w2_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.FLYING_INFANTRY, UNITS.RECON, UNITS.LIGHT_TANK,
					UNITS.MEDIUM_TANK, UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR, UNITS.ROCKET,
					UNITS.DRONE],
				move_type = MOVE_TYPE.AIR,
				w1_dmg_chart = {UNITS.RECON: 65, UNITS.LIGHT_TANK: 55, UNITS.MEDIUM_TANK: 25,
					UNITS.ARTILLERY: 65, UNITS.HEAVY_ARTILLERY: 65,
					UNITS.ARC_TOWER: 65, UNITS.ANTI_AIR: 25, UNITS.ROCKET: 65,
					UNITS.BATTLESHIP: 25},
				w2_dmg_chart = {UNITS.LIGHT_INFANTRY: 75, UNITS.HEAVY_INFANTRY: 75,
					UNITS.FLYING_INFANTRY: 75, UNITS.RECON: 30, UNITS.LIGHT_TANK: 6,
					UNITS.MEDIUM_TANK: 1, UNITS.ARTILLERY: 25, UNITS.HEAVY_ARTILLERY: 35,
					UNITS.ARC_TOWER: 25, UNITS.ANTI_AIR: 6, UNITS.ROCKET: 35,
					UNITS.DRONE: 65},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 9000,
				point_cost = 4,
				can_capture = false},
			UNITS.ANGEL:
				{unit_name = tr('ANGEL'),
				desc = tr('ANGEL'),
				movement = 9,
				energy = 99,
				energy_per_turn = 5,
				ammo = 6,
				weapon_1 = tr('ATA_CANNON'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.FLYING_INFANTRY, UNITS.DRONE, UNITS.ANGEL,
					UNITS.SKY_FORTRESS],
				w2_can_attack = [],
				move_type = MOVE_TYPE.AIR,
				w1_dmg_chart = {UNITS.FLYING_INFANTRY: 120,
					UNITS.DRONE: 100, UNITS.ANGEL: 55, UNITS.SKY_FORTRESS: 100},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 20000,
				point_cost = 7,
				can_capture = false},
			UNITS.SKY_FORTRESS:
				{unit_name = tr('SKY_FORTRESS'),
				desc = tr('SKY_FORTRESS_DESC'),
				movement = 7,
				energy = 99,
				energy_per_turn = 5,
				ammo = 6,
				weapon_1 = tr('AIR_BOMBS'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR,
					UNITS.ROCKET, UNITS.BATTLESHIP],
				w2_can_attack = [],
				move_type = MOVE_TYPE.AIR,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 110, UNITS.HEAVY_INFANTRY: 110,
					UNITS.RECON: 105, UNITS.LIGHT_TANK: 105, UNITS.MEDIUM_TANK: 95,
					UNITS.ARTILLERY: 105, UNITS.HEAVY_ARTILLERY: 105,
					UNITS.ARC_TOWER: 105, UNITS.ANTI_AIR: 95,
					UNITS.ROCKET: 105, UNITS.BATTLESHIP: 75},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.DIRECT,
				cost = 20000,
				point_cost = 7,
				can_capture = false},
			UNITS.BATTLESHIP:
				{unit_name = tr('BATTLESHIP'),
				desc = tr('BATTLESHIP_DESC'),
				movement = 6,
				energy = 99,
				energy_per_turn = 1,
				ammo = 9,
				weapon_1 = tr('DESTROYER_CANNON'),
				weapon_2 = tr('NONE'),
				w1_can_attack = [UNITS.LIGHT_INFANTRY, UNITS.HEAVY_INFANTRY,
					UNITS.RECON, UNITS.LIGHT_TANK, UNITS.MEDIUM_TANK,
					UNITS.ARTILLERY, UNITS.HEAVY_ARTILLERY,
					UNITS.ARC_TOWER, UNITS.ANTI_AIR,
					UNITS.ROCKET, UNITS.BATTLESHIP],
				w2_can_attack = [],
				move_type = MOVE_TYPE.WATER,
				w1_dmg_chart = {UNITS.LIGHT_INFANTRY: 95, UNITS.HEAVY_INFANTRY: 90,
					UNITS.RECON: 90, UNITS.LIGHT_TANK: 85, UNITS.MEDIUM_TANK: 55,
					UNITS.ARTILLERY: 80, UNITS.HEAVY_ARTILLERY: 85,
					UNITS.ARC_TOWER: 80, UNITS.ANTI_AIR: 85, UNITS.ROCKET: 85,
					UNITS.BATTLESHIP: 50},
				w2_dmg_chart = {},
				atk_type = ATTACK_TYPE.HEAVY_ARTILLERY,
				cost = 25000,
				point_cost = 5,
				can_capture = false},
			}

var terrain = { 
				TERRAIN.ROAD: {
					name = tr('ROAD'),
					desc = tr('ROAD_DESC'),
					stars = 0,
					move_values = {MOVE_TYPE.INFANTRY: 1, MOVE_TYPE.LIGHT_VEHICLE: 1,
						MOVE_TYPE.HEAVY_VEHICLE: 1, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.PLAINS: {
					name = tr('PLAINS'),
					desc = tr('PLAINS_DESC'),
					stars = 1,
					move_values = {MOVE_TYPE.INFANTRY: 1, MOVE_TYPE.LIGHT_VEHICLE: 1,
						MOVE_TYPE.HEAVY_VEHICLE: 1, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.FOREST: {
					name = tr('FOREST'),
					desc = tr('FOREST_DESC'),
					stars = 2,
					move_values = {MOVE_TYPE.INFANTRY: 1, MOVE_TYPE.LIGHT_VEHICLE: 2,
						MOVE_TYPE.HEAVY_VEHICLE: 2, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.HILL: {
					name = tr('HILL'),
					desc = tr('HILL_DESC'),
					stars = 3,
					move_values = {MOVE_TYPE.INFANTRY: 3, MOVE_TYPE.LIGHT_VEHICLE: 99,
						MOVE_TYPE.HEAVY_VEHICLE: 99, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.MOUNTAIN: {
					name = tr('MOUNTAIN'),
					desc = tr('MOUNTAIN_DESC'),
					stars = 4,
					move_values = {MOVE_TYPE.INFANTRY: 3, MOVE_TYPE.LIGHT_VEHICLE: 99,
						MOVE_TYPE.HEAVY_VEHICLE: 99, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.WASTELAND: {
					name = tr('WASTELAND'),
					desc = tr('WASTELAND_DESC'),
					stars = 3,
					move_values = {MOVE_TYPE.INFANTRY: 2, MOVE_TYPE.LIGHT_VEHICLE: 3,
						MOVE_TYPE.HEAVY_VEHICLE: 3, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.ENERGY_RELAY: {
					name = tr('ENERGY_RELAY'),
					desc = tr('ENERGY_RELAY_DESC'),
					stars = -1,
					move_values = {MOVE_TYPE.INFANTRY: 1, MOVE_TYPE.LIGHT_VEHICLE: 1,
						MOVE_TYPE.HEAVY_VEHICLE: 1, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.SCRAPYARD: {
					name = tr('SCRAPYARD'),
					desc = tr('SCRAPYARD_DESC'),
					stars = 3,
					move_values = {MOVE_TYPE.INFANTRY: 2, MOVE_TYPE.LIGHT_VEHICLE: 2,
						MOVE_TYPE.HEAVY_VEHICLE: 2, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.BEACH: {
					name = tr('BEACH'),
					desc = tr('BEACH_DESC'),
					stars = 0,
					move_values = {MOVE_TYPE.INFANTRY: 1, MOVE_TYPE.LIGHT_VEHICLE: 2,
						MOVE_TYPE.HEAVY_VEHICLE: 2, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 1}},
				TERRAIN.RIVER: {
					name = tr('RIVER'),
					desc = tr('RIVER_DESC'),
					stars = 0,
					move_values = {MOVE_TYPE.INFANTRY: 2, MOVE_TYPE.LIGHT_VEHICLE: 99,
						MOVE_TYPE.HEAVY_VEHICLE: 99, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 99}},
				TERRAIN.WATER: {
					name = tr('SEA'),
					desc = tr('SEA_DESC'),
					stars = 0,
					move_values = {MOVE_TYPE.INFANTRY: 99, MOVE_TYPE.LIGHT_VEHICLE: 99,
						MOVE_TYPE.HEAVY_VEHICLE: 99, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 1}},
				TERRAIN.REEF: {
					name = tr('REEF'),
					desc = tr('REEF_DESC'),
					stars = 2,
					move_values = {MOVE_TYPE.INFANTRY: 99, MOVE_TYPE.LIGHT_VEHICLE: 99,
						MOVE_TYPE.HEAVY_VEHICLE: 99, MOVE_TYPE.AIR: 1, MOVE_TYPE.WATER: 2}},
			}

var buildings = {BUILDINGS.RUINS: {
					name = tr('RUINS'),
					desc = tr('RUINS_DESC'),
					funds = 1000,
					repairs = [MOVE_TYPE.INFANTRY, MOVE_TYPE.LIGHT_VEHICLE,
						MOVE_TYPE.HEAVY_VEHICLE]},
				BUILDINGS.RUINS_2: {
					name = tr('RUINS'),
					desc = tr('RUINS_DESC'),
					funds = 1000,
					repairs = [MOVE_TYPE.INFANTRY, MOVE_TYPE.LIGHT_VEHICLE,
						MOVE_TYPE.HEAVY_VEHICLE]},
				BUILDINGS.FACTORY: {
					name = tr('FACTORY'),
					desc = tr('FACTORY_DESC'),
					funds = 500,
					repairs = [MOVE_TYPE.INFANTRY, MOVE_TYPE.LIGHT_VEHICLE,
						MOVE_TYPE.HEAVY_VEHICLE]},
				BUILDINGS.AIRPORT: {
					name = tr('AIRPORT'),
					desc = tr('AIRPORT_DESC'),
					funds = 500,
					repairs = [MOVE_TYPE.AIR]},
				BUILDINGS.PORT: {
					name = tr('PORT'),
					desc = tr('PORT_DESC'),
					funds = 500,
					repairs = [MOVE_TYPE.WATER]},
				BUILDINGS.RESEARCH: {
					name = tr('RESEARCH'),
					desc = tr('RESEARCH_DESC'),
					funds = 500,
					repairs = []},
				BUILDINGS.POWER_PLANT: {
					name = tr('POWER_PLANT'),
					desc = tr('POWER_PLANT_DESC'),
					funds = 500,
					repairs = []},
				BUILDINGS.RESEARCH_2: {
					name = tr('RESEARCH_2'),
					desc = tr('RESEARCH_2_DESC'),
					funds = 500,
					repairs = []},
				BUILDINGS.RESEARCH_3: {
					name = tr('RESEARCH_3'),
					desc = tr('RESEARCH_3_DESC'),
					funds = 500,
					repairs = []},
				}

var move_types = {  MOVE_TYPE.INFANTRY: {
						name = tr('INFANTRY_MOVE')},
					MOVE_TYPE.LIGHT_VEHICLE: {
						name = tr('LIGHT_VEHICLE_MOVE')},
					MOVE_TYPE.HEAVY_VEHICLE: {
						name = tr('HEAVY_VEHICLE_MOVE')},
					MOVE_TYPE.AIR: {
						name = tr('AIR_MOVE')},
					MOVE_TYPE.WATER: {
						name = tr('WATER_MOVE')}
				}

# unit stats are atk, def, and additional movement
var co_data: Dictionary = {
				COS.MARK0: {
					co_res = "res://resources/COs/mark0.tres",
					unit_stats = {UNITS.RECON: Vector3(1.2, 1.0, 0)},
				},
				COS.BANDIT: {
					co_res = "res://resources/COs/bandit.tres",
					unit_stats = {UNITS.LIGHT_INFANTRY: Vector3(1.1, 1.1, 0),
					UNITS.HEAVY_INFANTRY: Vector3(1.1, 1.1, 0), 
					UNITS.FLYING_INFANTRY: Vector3(1.1, 1.1, 0), UNITS.RECON: Vector3(1, 0.9, 0),
					UNITS.LIGHT_TANK: Vector3(1, 0.9, 0), UNITS.MEDIUM_TANK: Vector3(1, 0.9, 0),
					UNITS.ARTILLERY: Vector3(1, 0.9, 0), UNITS.HEAVY_ARTILLERY: Vector3(1, 0.9, 0),
					UNITS.ARC_TOWER: Vector3(1, 0.9, 0), UNITS.ANTI_AIR: Vector3(1, 0.9, 0),
					UNITS.ROCKET: Vector3(1, 0.9, 0), UNITS.DRONE: Vector3(1, 0.9, 0),
					UNITS.ANGEL: Vector3(1, 0.9, 0), UNITS.SKY_FORTRESS: Vector3(1, 0.9, 0),
					UNITS.BATTLESHIP: Vector3(1, 0.9, 0)},
				},
				COS.HUMAN_CO: {
					co_res = "res://resources/COs/human.tres",
					unit_stats = {UNITS.LIGHT_INFANTRY: Vector3(0.9, 1, 0),
					UNITS.HEAVY_INFANTRY: Vector3(0.9, 1, 0),
					UNITS.FLYING_INFANTRY: Vector3(0.9, 1, 0), UNITS.RECON: Vector3(1.2, 1.1, 0),
					UNITS.LIGHT_TANK: Vector3(1.2, 1.1, 0), UNITS.MEDIUM_TANK: Vector3(1.2, 1.1, 0),
					UNITS.ARTILLERY: Vector3(1.2, 1.1, 0), UNITS.HEAVY_ARTILLERY: Vector3(1.2, 1.1, 0),
					UNITS.ARC_TOWER: Vector3(1.2, 1.1, 0), UNITS.ANTI_AIR: Vector3(1.2, 1.1, 0),
					UNITS.ROCKET: Vector3(1.2, 1.1, 0), UNITS.DRONE: Vector3(0.9, 1, 0),
					UNITS.ANGEL: Vector3(0.9, 1, 0), UNITS.SKY_FORTRESS: Vector3(0.9, 1, 0),
					UNITS.BATTLESHIP: Vector3(0.9, 1, 0)},
				},
				COS.SCAVENGER: {
					co_res = "res://resources/COs/scavenger.tres",
					unit_stats = {},
				},
				COS.EVIL_MARK0: {
					co_res = "res://resources/COs/evil_mark0.tres",
					unit_stats = {UNITS.LIGHT_INFANTRY: Vector3(1.3, 1, 0),
					UNITS.HEAVY_INFANTRY: Vector3(1.3, 1, 0),
					UNITS.FLYING_INFANTRY: Vector3(1.3, 1, 0), UNITS.RECON: Vector3(1.3, 1, 0),
					UNITS.LIGHT_TANK: Vector3(1.3, 1, 0), UNITS.MEDIUM_TANK: Vector3(1.3, 1, 0),
					UNITS.ARTILLERY: Vector3(1.3, 1, 0), UNITS.HEAVY_ARTILLERY: Vector3(1.3, 1, 0),
					UNITS.ARC_TOWER: Vector3(1.3, 1, 0), UNITS.ANTI_AIR: Vector3(1.3, 1, 0),
					UNITS.ROCKET: Vector3(1.3, 1, 0), UNITS.DRONE: Vector3(1.3, 1, 0),
					UNITS.ANGEL: Vector3(1.3, 1, 0), UNITS.SKY_FORTRESS: Vector3(1.3, 1, 0),
					UNITS.BATTLESHIP: Vector3(1.3, 1, 0)},
				},
				COS.BOSS: {
					co_res = "res://resources/COs/boss.tres",
					unit_stats = {},
				},
}

enum UNITS {LIGHT_INFANTRY, HEAVY_INFANTRY, FLYING_INFANTRY,
	RECON, LIGHT_TANK, MEDIUM_TANK, ARTILLERY, HEAVY_ARTILLERY,
	ARC_TOWER, ANTI_AIR, ROCKET, DRONE, ANGEL, SKY_FORTRESS,
	BATTLESHIP}
enum MOVE_TYPE {INFANTRY, LIGHT_VEHICLE, HEAVY_VEHICLE, AIR, WATER}
enum ATTACK_TYPE {DIRECT, ARTILLERY, HEAVY_ARTILLERY}
enum TEAM {RED, BLUE, GREEN, YELLOW}
enum TURN_TYPE {ATTACK, CAPTURE, REPAIR, MOVE}
enum POWER_MOD {ATK_MOD, DEF_MOD, MOVE_MOD, CAP_MOD, FUNDS}

enum TERRAIN {PLAINS, FOREST, HILL, MOUNTAIN, WATER, ROAD, RIVER, WASTELAND, REEF, ENERGY_RELAY, SCRAPYARD, BEACH}
enum BUILDINGS {RUINS, RUINS_2, FACTORY, AIRPORT, PORT, RESEARCH, POWER_PLANT, RESEARCH_2, RESEARCH_3}
enum COS {MARK0, BANDIT, HUMAN_CO, SCAVENGER, EVIL_MARK0, BOSS}

########################
# GLOBAL AUX FUNCTIONS #
########################

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

func is_next_to_unit(unit: Unit, target_unit: Unit) -> bool:
	for dir in DIRECTIONS:
		if unit.position + (dir * tile_size) == target_unit.position:
			return true
	return false

# doesn't work correctly
func move_mouse_global(pos: Vector2) -> void:
	Input.warp_mouse_position(pos + Vector2(tile_size / 2, tile_size /2))
