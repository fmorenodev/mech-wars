extends PopupMenu

onready var UnitMenu = $'../UnitMenu'
onready var StatusMenu = $'../StatusInfoMenu'
onready var COMenu = $'../COMenu'

var active_team: Team

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	_err = signals.connect("turn_started", self, "_on_turn_started")
	_err = signals.connect("update_meter", self, "_on_meter_updated")
	
	add_item(tr('END_TURN'), 0)
	add_item(tr('TO_UNIT_MENU'), 1)
	add_item(tr('TO_STATUS_MENU'), 2)
	add_item(tr('TO_CO_MENU'), 3)
	add_item(tr('POWER_START'), 4)
	add_item(tr('SUPER_START'), 5)
	
	disable_powers()

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
			disable_powers()
		5:
			signals.emit_signal("super_start", active_team)
			disable_powers()

func _on_cancel_pressed() -> void:
	hide()

func _on_turn_started(value: Team) -> void:
	active_team = value
	check_power_enabled()

func _on_meter_updated(value: Team) -> void:
	if active_team == value:
		check_power_enabled()

func check_power_enabled() -> void:
	if active_team.is_power_enabled:
		set_item_disabled(4, false)
	else:
		set_item_disabled(4, true)
	if active_team.is_super_enabled:
		set_item_disabled(5, false)
	else:
		set_item_disabled(5, true)

func disable_powers() -> void:
	set_item_disabled(4, true)
	set_item_disabled(5, true)
