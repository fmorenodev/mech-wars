extends VBoxContainer

var row = preload("res://ui/TableRow.tscn")
onready var Table = $ScrollContainer/TableContent

var row_n: int

func _ready():
	var _err = signals.connect("send_teams_to_table", self, "set_data")
	$Header/Team.text = tr("STATUS_TEAM_HEADER")
	$Header/Units.text = tr("STATUS_UNITS_HEADER")
	$Header/Lost.text = tr("STATUS_LOST_HEADER")
	$Header/Bases.text = tr("STATUS_BASES_HEADER")
	$Header/Funds.text = tr("STATUS_FUNDS_HEADER")
	$Header/Income.text = tr("STATUS_INCOME_HEADER")
	$Header/UnitPoints.text = tr("STATUS_UNIT_POINTS_HEADER")

func set_data(teams: Array) -> void:
	row_n = 0
	for child in Table.get_children():
		Table.remove_child(child)
		child.queue_free()
	for team in teams:
		set_row(team)

func set_row(team: Team) -> void:
	var row_instance = row.instance()
	row_instance.name = str(row_n)
	row_n += 1
	Table.add_child(row_instance)
	
	var instance_path = "ScrollContainer/TableContent/%s/%s"
	# TODO: add team icons
	get_node(instance_path % [row_instance.name, "/HBoxContainer/TextureButton"]).texture_normal = sp.team_icons[team.team_id]
	get_node(instance_path % [row_instance.name, "/Label"]).text = str(team.units.size())
	get_node(instance_path % [row_instance.name, "/Label2"]).text = str(team.lost_units)
	get_node(instance_path % [row_instance.name, "/Label3"]).text = str(team.buildings.size())
	get_node(instance_path % [row_instance.name, "/Label4"]).text = str(team.funds)
	get_node(instance_path % [row_instance.name, "/Label5"]).text = str(team.funds_per_turn)
	get_node(instance_path % [row_instance.name, "/Label6"]).text = "%d / %d" % [team.unit_points, team.max_unit_points]
