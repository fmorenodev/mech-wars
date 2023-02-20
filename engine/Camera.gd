extends Camera2D

#onready var CursorTileMap = get_parent()
#var cursor_pos: Vector2
#
#func _process(_delta) -> void:
#	cursor_pos = CursorTileMap.global_cursor_pos
#	if cursor_pos.x > 0 and cursor_pos.y > 0 and cursor_pos.x < 100 and cursor_pos.y < 600:
#		position.x -= gl.tile_size
#	elif cursor_pos.x > 924 and cursor_pos.y > 0 and cursor_pos.x < 1024 and cursor_pos.y < 600:
#		position.x += gl.tile_size
