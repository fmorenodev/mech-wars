#warning-ignore-all:unused_signal
extends Node

signal turn_ended
signal turn_started(active_team)

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

signal send_units_to_table(units)
signal send_teams_to_table(teams)
signal open_detailed_info_menu(pos)
signal funds_updated(funds)
signal funds_per_turn_updated(funds_per_turn)
