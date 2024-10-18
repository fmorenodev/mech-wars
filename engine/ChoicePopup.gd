extends PopupMenu

var team: Team
var power_ups: Array

func _ready() -> void:
	var _err = signals.connect("choose_power_up", self, "_on_choose_power_up")
	_err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_choose_power_up(_team: Team, _power_ups: Array) -> void:
	team = _team
	power_ups = _power_ups
	for power_up in power_ups.keys():
		var label_text
		add_item(label_text, power_up.id)

func _on_id_pressed(id: int) -> void:
	pass

func _on_cancel_pressed() -> void:
	hide()
