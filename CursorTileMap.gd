extends TileMap

var cursor_pos: Vector2
onready var Main = get_parent()

func move_cursor(new_pos: Vector2) -> void:
	if !Main.is_off_borders(new_pos) and (Main.active_unit == null or new_pos in Main.walkable_cells and !Main.active_unit.is_moving):
		set_cellv(cursor_pos, -1)
		cursor_pos = new_pos
		set_cellv(cursor_pos, 0)
		gl.emit_signal("cursor_moved", cursor_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		move_cursor(gl.clamp(world_to_map(event.position)))
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		# if unit or building is there, change mode. if not, open menu
		gl.emit_signal("accept_pressed", cursor_pos)
		get_tree().set_input_as_handled() # ?
	
	if event.is_action_pressed("ui_up", true):
		move_cursor(cursor_pos + Vector2.UP)
	if event.is_action_pressed("ui_down", true):
		move_cursor(cursor_pos + Vector2.DOWN)
	if event.is_action_pressed("ui_left", true):
		move_cursor(cursor_pos + Vector2.LEFT)
	if event.is_action_pressed("ui_right", true):
		move_cursor(cursor_pos + Vector2.RIGHT)

	if Main.active_unit and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_click")):
		gl.emit_signal("cancel_pressed")
