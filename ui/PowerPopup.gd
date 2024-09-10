extends PopupPanel

onready var title_label = $VBoxContainer/TitleLabel
onready var power_name = $VBoxContainer/PowerName
onready var Main = $"../../.."
onready var timer = $Timer

func _ready():
	var _err = signals.connect("power_start", self, "_on_power_start")
	_err = signals.connect("super_start", self, "_on_super_start")

func _on_power_start(team: Team) -> void:
	power_name.text = tr(team.co_resource.power_name)
	title_label.text = tr("POWER_USED")
	popup()
	timer.start()

func _on_super_start(team: Team) -> void:
	power_name.text = tr(team.co_resource.super_name)
	title_label.text = tr("SUPER_USED")
	popup()
	timer.start()

func _on_Timer_timeout():
	hide()
