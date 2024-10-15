extends PanelContainer

onready var funds = $VBoxContainer/HBoxContainer/Funds
onready var funds_per_turn = $VBoxContainer/HBoxContainer/FundsPerTurn
onready var co_icon = $VBoxContainer/HBoxContainer/COIcon
onready var power_stars = $VBoxContainer/HBoxContainer2/PowerStars
onready var super_stars = $VBoxContainer/HBoxContainer2/SuperStars
onready var status_label = $VBoxContainer/Status

var active_team: Team
var co: COData

func _ready() -> void:
	var _err = signals.connect("turn_started", self, "_on_turn_started")
	_err = signals.connect("funds_updated", self, "_on_funds_updated")
	_err = signals.connect("funds_per_turn_updated", self, "_on_funds_per_turn_updated")
	_err = signals.connect("update_meter", self, "_on_meter_updated")
	_err = signals.connect("power_start", self, "_on_power_start")
	_err = signals.connect("super_start", self, "_on_super_start")

func _on_turn_started(team: Team) -> void:
	active_team = team
	co = active_team.co_resource
	co_icon.texture = sp.team_icons[team.team_id]
	
	power_stars.show()
	power_stars.texture_under = co.power_star_empty
	power_stars.texture_progress = co.power_star
	power_stars.max_value = co.power_meter_size
	power_stars.value = active_team.power_meter_amount
	
	super_stars.show()
	super_stars.texture_under = co.super_star_empty
	super_stars.texture_progress = co.super_star
	super_stars.max_value = co.super_meter_size
	super_stars.value = active_team.power_meter_amount - co.power_meter_size
	
	status_label.hide()

func _on_funds_updated(new_funds: int) -> void:
	funds.text = str(new_funds)

func _on_funds_per_turn_updated(new_funds: int) -> void:
	funds_per_turn.text = "(+ " + str(new_funds) + ")"

func _on_meter_updated(value: Team) -> void:
	if (value == active_team):
		power_stars.value = active_team.power_meter_amount
		super_stars.value = active_team.power_meter_amount - co.power_meter_size

func _on_power_start(_team: Team) -> void:
	power_stars.value = 0
	super_stars.value = 0

	power_stars.hide()
	super_stars.hide()
	status_label.text = "POWER ACTIVE!"
	status_label.show()

func _on_super_start(_team: Team) -> void:
	power_stars.hide()
	super_stars.hide()
	status_label.text = "SUPER ACTIVE!"
	status_label.show()

func _on_mouse_entered() -> void:
	if get_anchor(MARGIN_LEFT) == 0:
		set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT, 3)
	else:
		set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT, 3)
