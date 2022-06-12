extends Resource

class_name Team

var color: int
var units := []
var buildings := []
var funds := 0
var co # TODO

func _init(_color: int) -> void:
	color = _color

func add_unit(unit: Unit) -> void:
	unit.team = color
	units.append(unit)

func add_building(building) -> void:
	buildings.append(building)
