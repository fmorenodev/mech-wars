extends TileMap

var cursor_pos: Vector2
var global_cursor_pos: Vector2
onready var Main = $"../.."
onready var GameCamera = $GameCamera

var zoomed: bool = false # disabled for now
var target_index: int = 1

func move_cursor(new_pos: Vector2, cursor: int = 0) -> void:
	if !gl.is_off_borders(new_pos) and (Main.active_unit == null \
	or (new_pos in Main.walkable_cells and !Main.active_unit.is_moving) or (Main.selecting_targets)):
		if new_pos != cursor_pos:
			clear()
			cursor_pos = new_pos
			global_cursor_pos = map_to_world(cursor_pos)
			set_cellv(cursor_pos, cursor)
			signals.emit_signal("cursor_moved", cursor_pos)

func _unhandled_input(event: InputEvent) -> void:
	if Main.selecting_targets:
		if event is InputEventMouseMotion:
			var adjusted_pos = gl.clamp(world_to_map(event.position * GameCamera.zoom))
			var distances = {}
			for pos in Main.targets:
				distances[adjusted_pos.distance_to(pos)] = pos
			move_cursor(distances[distances.keys().min()], 1)
		elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") \
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			if Main.targets.size() > 1:
				move_cursor(Main.targets[target_index], 1)
				target_index = (target_index + 1) % (Main.targets.size())
		elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
			var possible_unit = Main.is_unit_in_position(cursor_pos)
			var unit_pos = world_to_map(possible_unit.position)
			if Main.targets.has(unit_pos):
				signals.emit_signal("target_selected", cursor_pos)
				target_index = 1
				set_cellv(cursor_pos, 0)
		elif event.is_action_pressed("right_click") or event.is_action_pressed("ui_cancel"):
			signals.emit_signal("cancel_pressed")
	elif event is InputEventMouseMotion:
		var adjusted_pos = gl.clamp(world_to_map(event.position * GameCamera.zoom))
		move_cursor(adjusted_pos)
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
#	elif event is InputEventMouseButton:
#		if event.is_pressed():
#			if event.button_index == BUTTON_WHEEL_UP and zoomed == true:
#				GameCamera.zoom += Vector2(0.5, 0.5)
#				zoomed = false
#			if event.button_index == BUTTON_WHEEL_DOWN and zoomed == false:
#				GameCamera.zoom -= Vector2(0.5, 0.5)
#				zoomed = true
	elif event.is_action_pressed("ui_detailed_info", true):
		signals.emit_signal("open_detailed_info_menu", cursor_pos)
