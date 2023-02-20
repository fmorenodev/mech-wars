extends PopupMenu

onready var UnitMenu = $'../UnitMenu'
onready var StatusMenu = $'../StatusInfoMenu'

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	add_item(tr('END_TURN'), 0)
	add_item(tr('TO_UNIT_MENU'), 1)
	add_item(tr('TO_STATUS_MENU'), 2)

func _on_id_pressed(id: int) -> void:
	match id:
		0:
			signals.emit_signal("turn_ended")
		1:
			UnitMenu.popup()
		2:
			StatusMenu.popup()

func _on_cancel_pressed() -> void:
	hide()
