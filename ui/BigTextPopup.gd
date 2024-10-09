extends PopupPanel

var victory_texture = load("res://assets/gui/popup_text/victory.png")
var defeat_texture = load("res://assets/gui/popup_text/defeat.png")
var player_turn_texture = load("res://assets/gui/popup_text/player_turn.png")
var enemy_turn_texture = load("res://assets/gui/popup_text/enemy_turn.png")
var power_texture = load("res://assets/gui/popup_text/power_used.png")
var super_texture = load("res://assets/gui/popup_text/super_used.png")

onready var Main = $"../../.."
onready var message = $Message

var team: Team

func _ready() -> void:
	var _err = signals.connect("turn_started", self, "_on_turn_started")
	_err = signals.connect("team_defeated", self, "_on_team_defeated")
	_err = signals.connect("power_start", self, "_on_power_start")
	_err = signals.connect("super_start", self, "_on_super_start")

func _on_turn_started(_team: Team) -> void:
	team = _team
	if team.defeated:
		_on_tween_finished()
		return
	# TODO: change the text to "blue team", "red team" or something like that
	if team.is_player:
		message.texture = player_turn_texture
	else:
		message.texture = enemy_turn_texture
	var tween = tween_fade()
	tween.connect("finished", self, "_on_tween_finished")

func _on_team_defeated(_team: Team) -> void:
	team = _team
	
	var game_ended := false
	var victory := false
	var defeated_teams := 0
	var ally_teams := 0
	var defeated_ally_teams := 0
	var defeated_players := 0
	var player_teams := 0
	for t in Main.teams:
		if t.allegiance == team.allegiance and t != team:
			ally_teams += 1
			if t.defeated:
				defeated_teams += 1
				defeated_ally_teams += 1
		elif t.defeated:
			defeated_teams += 1
		if t.is_player:
			if t.defeated:
				defeated_players += 1
			player_teams += 1
	if defeated_players >= player_teams and defeated_players > 0:
		game_ended = true
	elif defeated_teams == Main.teams.size() -1:
		game_ended = true
		victory = true
	elif defeated_ally_teams == ally_teams and !Main.is_ffa:
		game_ended = true
		if !team.is_player:
			victory = true
	
	if game_ended:
		if victory:
			message.texture = victory_texture
		else:
			message.texture = defeat_texture
		Main.disable_input(true)
		modulate.a = 0
		popup()
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 2)

func _on_power_start(_team: Team) -> void:
	team = _team
	message.texture = power_texture
	var tween = tween_fade()
	tween.connect("finished", self, "_on_power_tween_finished")

func _on_super_start(_team: Team) -> void:
	team = _team
	message.texture = super_texture
	var tween = tween_fade()
	tween.connect("finished", self, "_on_power_tween_finished")

func tween_fade() -> Tween:
	Main.disable_input(true)
	modulate.a = 0
	popup()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	tween.set_trans(Tween.TRANS_CUBIC)
	return tween

func _on_tween_finished() -> void:
	hide()
	Main.disable_input(false)
	if !team.is_player:
		signals.emit_signal("start_ai_turn", team)

func _on_power_tween_finished() -> void:
	hide()
	Main.disable_input(false)
	if !team.is_player:
		signals.emit_signal("next_ai_unit_turn")
