extends PopupMenu

const move_icon: Texture = preload("res://assets/gui/action_icons/move_arrow.png")
const cancel_icon: Texture = preload("res://assets/gui/action_icons/cancel.png")
const attack_icon: Texture = preload("res://assets/gui/action_icons/attack.png")
const capture_icon: Texture = preload("res://assets/gui/action_icons/capture.png")
const join_icon: Texture = preload("res://assets/gui/action_icons/join.png")

enum menu_options {
	MOVE,
	CANCEL,
	ATTACK,
	CAPTURE,
	JOIN
}

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	match id:
		menu_options.MOVE:
			signals.emit_signal("move_action")
		menu_options.CANCEL:
			signals.emit_signal("cancel_action")
		menu_options.ATTACK:
			signals.emit_signal("attack_action")
		menu_options.CAPTURE:
			signals.emit_signal("capture_action")
		menu_options.JOIN:
			signals.emit_signal("join_action")

func add_option(id: int) -> void:
	match id:
		menu_options.MOVE:
			add_icon_item(move_icon, tr("MOVE_ACTION"), id)
		menu_options.CANCEL:
			add_icon_item(cancel_icon, tr("CANCEL_ACTION"), id)
		menu_options.ATTACK:
			add_icon_item(attack_icon, tr("ATTACK_ACTION"), id)
		menu_options.CAPTURE:
			add_icon_item(capture_icon, tr("CAPTURE_ACTION"), id)
		menu_options.JOIN:
			add_icon_item(join_icon, tr("JOIN_ACTION"), id)

func generate_menu(options: PoolIntArray) -> void:
	clear()
	for id in options:
		add_option(id)
	if !options.has(menu_options.JOIN):
		add_option(menu_options.MOVE)
	add_option(menu_options.CANCEL)

func _on_cancel_pressed() -> void:
	hide()
