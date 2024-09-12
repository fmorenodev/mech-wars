extends PopupPanel

var victory_texture = load("res://assets/gui/victory.png")
var defeat_texture = load("res://assets/gui/defeat.png")
var player_turn_texture = load("res://assets/gui/player_turn.png")
var enemy_turn_texture = load("res://assets/gui/enemy_turn.png")
var power_texture = load("res://assets/gui/power_used.png")
var super_texture = load("res://assets/gui/super_used.png")

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
	if team.is_player:
		message.texture = player_turn_texture
	else:
		message.texture = enemy_turn_texture
	var tween = tween_fade()
	tween.connect("finished", self, "_on_tween_finished")

func _on_team_defeated(_team: Team) -> void:
	team = _team
	if team.is_player:
		message.texture = defeat_texture
	else:
		message.texture = victory_texture
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
