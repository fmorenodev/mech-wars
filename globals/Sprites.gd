extends Node

var light_inf = load("res://assets/units/light_infantry/light_infantry.tres")
var artillery = load("res://assets/units/artillery/artillery.tres")
var sprites = {gl.UNITS.LIGHT_INFANTRY: light_inf, gl.UNITS.ARTILLERY: artillery}
var greyscale_mat: Material = preload("res://assets/greyscale_material.tres")

var neutral_buildings = load("res://assets/map/building_tileset.png")
var red_buildings = load("res://assets/map/building_tileset_red.png")
var blue_buildings = load("res://assets/map/building_tileset_blue.png")
var building_sprites = {-1: neutral_buildings, gl.TEAM.RED: red_buildings, gl.TEAM.BLUE: blue_buildings}

func get_sprite(id: int) -> Resource:
	return sprites[id]

func get_building_sprite(id: int) -> Resource:
	return building_sprites[id]
