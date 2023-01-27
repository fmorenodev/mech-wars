#warning-ignore-all:unused_signal
extends Node

signal turn_ended

signal cursor_moved(pos)
signal accept_pressed(pos)
signal cancel_pressed

signal cancel_action
signal move_action
signal attack_action
signal capture_action

signal target_selected(pos)

signal unit_added(unit_id, team_id, pos)
signal unit_deleted(unit)

signal start_ai_turn(team)
signal next_ai_unit_turn(unit)
signal end_ai_turn

signal move_completed(unit)
signal action_completed
