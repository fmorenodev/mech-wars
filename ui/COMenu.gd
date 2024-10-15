extends TabContainer

const co_tab = preload("res://ui/COTab.tscn")

func _ready() -> void:
	var _err = signals.connect("send_cos_to_menu", self, "set_data")

func set_data(co_array: Array) -> void:
	var i := 0
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for co_res in co_array:
		var new_co_tab = co_tab.instance()
		add_child(new_co_tab)
		new_co_tab.co = co_res
		new_co_tab.icon.texture = sp.team_icons[i]
		set_tab_title(i, co_res.name)
		i += 1
