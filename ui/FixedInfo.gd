extends PanelContainer

onready var funds = $VBoxContainer/HBoxContainer/Funds
onready var funds_per_turn = $VBoxContainer/HBoxContainer/FundsPerTurn
onready var co_icon = $VBoxContainer/COIcon
onready var power_stars = $VBoxContainer/PowerStars

var active_team: Team

func _ready() -> void:
	var _err = signals.connect("turn_started", self, "_on_turn_started")
	_err = signals.connect("funds_updated", self, "_on_funds_updated")
	_err = signals.connect("funds_per_turn_updated", self, "_on_funds_per_turn_updated")

func _on_turn_started(value: Team) -> void:
	active_team = value
	# co_icon.texture = active_team.co_resource.texture
	# TODO: make a repeatable star texture or a bar for the power charge

func _on_funds_updated(new_funds: int) -> void:
	funds.text = str(new_funds)

func _on_funds_per_turn_updated(new_funds: int) -> void:
	funds_per_turn.text = "+ " + str(new_funds)

func _on_mouse_entered() -> void:
	if get_anchor(MARGIN_LEFT) == 0:
		set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT, 3)
	else:
		set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT, 3)
