extends PopupMenu

onready var move_icon: Texture = preload("res://assets/gui/move_arrow.png")
onready var cancel_icon: Texture = preload("res://assets/gui/cancel.png")
onready var attack_icon: Texture = preload("res://assets/gui/attack.png")
onready var capture_icon: Texture = preload("res://assets/gui/capture.png")

enum menu_options {
	MOVE,
	CANCEL,
	ATTACK,
	CAPTURE
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

func generate_menu(options: PoolIntArray) -> void:
	clear()
	for id in options:
		add_option(id)
	add_option(menu_options.MOVE)
	add_option(menu_options.CANCEL)

func _on_cancel_pressed() -> void:
	hide()
