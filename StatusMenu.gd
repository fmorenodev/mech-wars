extends PopupMenu

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	match id:
		0:
			pass
		1:
			signals.emit_signal("turn_ended")

func _on_cancel_pressed() -> void:
	hide()
