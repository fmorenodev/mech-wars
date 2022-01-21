
class_name PathTileMap
extends TileMap

var current_path := PoolVector2Array()

func draw(start_pos: Vector2, end_pos: Vector2) -> void:
	clear()
	current_path = gl.a_star.get_point_path(gl.a_star.get_closest_point(start_pos), gl.a_star.get_closest_point(end_pos))
	print(current_path)
	for cell in current_path:
		set_cellv(cell, 0)
	update_bitmask_region()
