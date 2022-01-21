extends Node

var light_inf = load("res://assets/units/light_infantry.tres")
var sprites = {gl.UNITS.LIGHT_INFANTRY: light_inf}

func get_sprite(id: int) -> SpriteFrames:
	return sprites[id]
