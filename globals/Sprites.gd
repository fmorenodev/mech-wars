extends Node

var light_inf = load("res://assets/units/light_infantry/light_infantry.tres")
var artillery = load("res://assets/units/artillery/artillery.tres")
var sprites = {gl.UNITS.LIGHT_INFANTRY: light_inf, gl.UNITS.ARTILLERY: artillery}

func get_sprite(id: int) -> SpriteFrames:
	return sprites[id]
