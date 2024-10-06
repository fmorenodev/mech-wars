class_name PathTileMap

extends TileMap

var current_path := PoolVector2Array()

func draw(start_pos: Vector2, end_pos: Vector2, unit: Unit) -> void:
	clear()
	var unit_a_star = astar.a_star_maps[unit.team_id][unit.move_type]
	current_path = unit_a_star.get_point_path(unit_a_star.get_closest_point(start_pos), unit_a_star.get_closest_point(end_pos))
	for cell in current_path:
		set_cellv(cell, 0)
	update_bitmask_region()
