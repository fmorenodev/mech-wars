extends PopupMenu

onready var move_icon: Texture = preload("res://assets/gui/move_arrow.png")
onready var cancel_icon: Texture = preload("res://assets/gui/cancel.png")
onready var attack_icon: Texture = preload("res://assets/gui/attack.png")

enum menu_options {
	MOVE,
	CANCEL,
	ATTACK
}

func _ready() -> void:
	var _err = connect("id_pressed", self, "_on_id_pressed")
	_err = gl.connect("cancel_pressed", self, "_on_cancel_pressed")

func _on_id_pressed(id: int) -> void:
	match id:
		menu_options.MOVE:
			gl.emit_signal("move_action")
		menu_options.CANCEL:
			gl.emit_signal("cancel_action")
		menu_options.ATTACK:
			gl.emit_signal("attack_action")

func add_option(id: int) -> void:
	match id:
		menu_options.MOVE:
			add_icon_item(move_icon, "Move", id)
		menu_options.CANCEL:
			add_icon_item(cancel_icon, "Cancel", id)
		menu_options.ATTACK:
			add_icon_item(attack_icon, "Attack", id)

func generate_menu(options: PoolIntArray) -> void:
	clear()
	for id in options:
		add_option(id)
	add_option(menu_options.MOVE)
	add_option(menu_options.CANCEL)

func _on_cancel_pressed() -> void:
	hide()
