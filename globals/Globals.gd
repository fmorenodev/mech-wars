#warning-ignore-all:unused_signal
extends Node

var DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
enum UNITS {LIGHT_INFANTRY}
enum MOVE_TYPE {LIGHT_INF}
enum TEAM {RED, BLUE}
var tile_size: int = 24
var map_size: Vector2 = Vector2(14, 11)
var a_star: AStar2D

signal cursor_moved(pos)
signal accept_pressed(pos)
signal cancel_pressed

func clamp(grid_position: Vector2) -> Vector2:
	var result := grid_position
	result.x = clamp(result.x, 0, map_size.x - 1.0)
	result.y = clamp(result.y, 0, map_size.y - 1.0)
	return result
