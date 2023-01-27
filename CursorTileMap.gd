extends TileMap

var cursor_pos: Vector2
onready var Main = get_parent()

var target_index: int = 1

func move_cursor(new_pos: Vector2, cursor: int = 0) -> void:
	if !Main.is_off_borders(new_pos) and (Main.active_unit == null \
	or (new_pos in Main.walkable_cells and !Main.active_unit.is_moving) or (Main.selecting_targets)):
		if new_pos != cursor_pos:
			clear()
			cursor_pos = new_pos
			set_cellv(cursor_pos, cursor)
			signals.emit_signal("cursor_moved", cursor_pos)

func _unhandled_input(event: InputEvent) -> void:
	if Main.selecting_targets:
		if event is InputEventMouseMotion:
			var pos = gl.clamp(world_to_map(event.position))
			if pos in Main.targets:
				move_cursor(pos, 1)
		elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") \
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			move_cursor(Main.targets[target_index], 1)
			target_index = (target_index + 1) % (Main.targets.size())
		elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
			if Main.is_unit_in_position(cursor_pos):
				signals.emit_signal("target_selected", cursor_pos)
				target_index = 1
				set_cellv(cursor_pos, 0)
		elif event.is_action_pressed("right_click") or event.is_action_pressed("ui_cancel"):
			signals.emit_signal("cancel_pressed")
	elif event is InputEventMouseMotion:
		move_cursor(gl.clamp(world_to_map(event.position)))
	elif (Main.action_menu_open and event.is_action_pressed("click")) \
	or (event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_click")):
		signals.emit_signal("cancel_pressed")
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		signals.emit_signal("accept_pressed", cursor_pos)
	
	elif event.is_action_pressed("ui_up", true):
		move_cursor(cursor_pos + Vector2.UP)
	elif event.is_action_pressed("ui_down", true):
		move_cursor(cursor_pos + Vector2.DOWN)
	elif event.is_action_pressed("ui_left", true):
		move_cursor(cursor_pos + Vector2.LEFT)
	elif event.is_action_pressed("ui_right", true):
		move_cursor(cursor_pos + Vector2.RIGHT)
