extends Resource

class_name Team

var color: int
var units := []
var buildings := []
var funds := 0
var is_player: bool
var co # TODO

func _init(_color: int, _is_player: bool) -> void:
	color = _color
	is_player = _is_player

func add_unit(unit: Unit) -> void:
	unit.team = color
	units.append(unit)

func add_building(building) -> void:
	buildings.append(building)
