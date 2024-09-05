extends PopupMenu

onready var UnitMenu = $'../UnitMenu'
onready var StatusMenu = $'../StatusInfoMenu'
onready var COMenu = $'../COMenu'

var active_team: Team

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	_err = signals.connect("turn_started", self, "_on_turn_started")
	add_item(tr('END_TURN'), 0)
	add_item(tr('TO_UNIT_MENU'), 1)
	add_item(tr('TO_STATUS_MENU'), 2)
	add_item(tr('TO_CO_MENU'), 3)
	add_item(tr('POWER_START'), 4)
	add_item(tr('SUPER_START'), 5)

func _on_id_pressed(id: int) -> void:
	match id:
		0:
			signals.emit_signal("turn_ended")
		1:
			UnitMenu.popup()
		2:
			StatusMenu.popup()
		3:
			COMenu.popup()
		4:
			signals.emit_signal("power_start", active_team)
		5:
			signals.emit_signal("super_start", active_team)

func _on_cancel_pressed() -> void:
	hide()

func _on_turn_started(value: Team) -> void:
	active_team = value
