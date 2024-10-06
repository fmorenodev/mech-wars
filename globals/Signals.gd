#warning-ignore-all:unused_signal
extends Node

signal turn_ended
signal turn_started(active_team)

# VICTORY AND DEFEAT
signal team_defeated(team)

# PLAYER INPUT #
signal cursor_moved(pos)
signal accept_pressed(pos)
signal cancel_pressed

signal cancel_action
signal move_action
signal attack_action
signal capture_action

signal target_selected(pos)

# UNIT CREATION / DESTRUCTION #
signal unit_added(unit_id, team_id, pos)
signal unit_deleted(unit)

# AI TURN #
signal start_ai_turn(team)
signal next_ai_unit_turn
signal end_ai_turn

# UNIT MOVEMENT #
signal move_completed(unit)
signal action_completed

# INFO MENUS #
signal send_units_to_table(units)
signal send_teams_to_table(teams)
signal open_detailed_info_menu(pos)
signal send_cos_to_menu(cos_data)
signal funds_updated(funds)
signal funds_per_turn_updated(funds_per_turn)

# CO #
signal power_start(team)
signal super_start(team)
signal update_meter(team)

signal change_unlocked_factory_units(unlocked, team_id)
