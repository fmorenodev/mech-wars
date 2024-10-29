extends PopupMenu

var team: Team
var power_mods: Array

func _ready() -> void:
	var _err = signals.connect("choose_power_mod", self, "_on_choose_power_mod")
	_err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_choose_power_mod(_team: Team, _power_mods: Array) -> void:
	team = _team
	power_mods = _power_mods
	
	clear()
	var i := 0
	for power_mod in power_mods:
		var label_text: String
		var real_amount: float
		match power_mod.id:
			gl.POWER_MOD.ATK_MOD, gl.POWER_MOD.DEF_MOD, gl.POWER_MOD.CAP_MOD:
				real_amount = power_mod.amount * 100
			_:
				real_amount = power_mod.amount
		if power_mod.amount >= 0:
			var aux_text = "+%d" % real_amount
			label_text = tr(power_mod.text) % aux_text
		else:
			var aux_text = "%d" % real_amount
			label_text = tr(power_mod.text) % aux_text
		add_item(label_text, i)
		i += 1
	popup()

func _on_id_pressed(id: int) -> void:
	power_mods[id].apply_mod(team)

func _on_cancel_pressed() -> void:
	hide()
