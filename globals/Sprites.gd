extends Node

var light_inf = load("res://assets/units/light_infantry/light_infantry.tres")
var heavy_inf = load("res://assets/units/heavy_infantry/heavy_infantry.tres")
var recon = load("res://assets/units/recon/recon.tres")
var light_tank = load("res://assets/units/light_tank/light_tank.tres")
var medium_tank = load("res://assets/units/medium_tank/medium_tank.tres")
var anti_air = load("res://assets/units/anti_air/anti_air.tres")
var artillery = load("res://assets/units/artillery/artillery.tres")
var heavy_artillery = load("res://assets/units/heavy_artillery/heavy_artillery.tres")
var drone = load("res://assets/units/drone/drone.tres")
var battleship = load("res://assets/units/battleship/battleship.tres")
var sprites = { gl.UNITS.LIGHT_INFANTRY: light_inf, gl.UNITS.HEAVY_INFANTRY: heavy_inf,
				gl.UNITS.RECON: recon, gl.UNITS.LIGHT_TANK: light_tank,
				gl.UNITS.MEDIUM_TANK: medium_tank, gl.UNITS.ANTI_AIR: anti_air,
				gl.UNITS.ARTILLERY: artillery, gl.UNITS.HEAVY_ARTILLERY: heavy_artillery,
				gl.UNITS.DRONE: drone, gl.UNITS.BATTLESHIP: battleship }

var greyscale_mat: Material = preload("res://assets/units/greyscale_material.tres")
var swap_mat: Material = preload("res://assets/units/swap_material.tres")

var neutral_buildings = load("res://assets/map/building_tileset.png")
var red_buildings = load("res://assets/map/building_tileset_red.png")
var blue_buildings = load("res://assets/map/building_tileset_blue.png")
var building_sprites = {-1: neutral_buildings, gl.TEAM.RED: red_buildings, gl.TEAM.BLUE: blue_buildings}

func get_sprite(id: int) -> Resource:
	return sprites[id]

func get_building_sprite(id: int) -> Resource:
	return building_sprites[id]
