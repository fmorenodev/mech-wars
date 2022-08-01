extends Node

var units = []
var buildings = []

onready var Main = get_parent()

# final objectives: 
# - kill all enemy units
# - capture a building
# - defend a building

# short term goals
# - capture buildings in range
# - kill enemy units in range, calculating value and retaliation
# - advance troops
# - create new troops

# priority between units (advanced AI)
# - calculate "turn value" of each unit's optimal turn
# - make a copy of the board status and run the most optimal turn, then run each other turn again
# - if the turn values are better or in a certain threshold, or there are more > 0 turn values, do the turn
# - else, go with the second most optimal, then repeat until the best set of turns are chosen

# kinds of ai
# - aggresive
# - defensive
# - easy: will move forward and attack everything
# - hard: calculates best movement

# basic actions
# - move unit
# - create unit
# - attack unit
# - capture
# - retreat to heal

func _ready() -> void:
	var _err = signals.connect("start_ai_turn", self, "start_turn")

func start_turn(team: Team) -> void:
	for unit in team.units:
		# ATTACK
		var attack_turn_value = 0
		if unit.atk_type != -1: # can attack
			var targets = Main.check_all_targets(unit)
			var chosen_target = null
			for target_pos in targets:
				var target = Main.is_unit_in_position(target_pos)
				var value = Main.calc_dmg_value(unit, target)
				if value > attack_turn_value:
					attack_turn_value = value
					chosen_target = target
			print(attack_turn_value)
		# CAPTURE
		var building_turn_value = 0
		if unit.can_capture:
			var building_targets = Main.check_buildings(unit, false)
			var chosen_building = null
			for target_pos in building_targets:
				var target = Main.is_building_in_position(target_pos)
				var value = 0
				if target.team == -1:
					value = 100
				elif target.team != unit.team:
					value = 150
				if target.type != gl.BUILDINGS.RUINS or target.type != gl.BUILDINGS.RUINS_2:
					value += 51
				if value > building_turn_value:
					building_turn_value = value
					chosen_building = target
			print(building_turn_value)
		# RETREAT
		var repair_turn_value = 0
		if unit.health <= 2:
			var repair_targets = Main.check_buildings(unit, true)
			var chosen_repair_building = null
			for target_pos in repair_targets:
				var target = Main.is_building_in_position(target_pos)
				if target.type == gl.BUILDINGS.RUINS or target.type == gl.BUILDINGS.RUINS_2:
					repair_turn_value = unit.cost / 1000 * 2
					chosen_repair_building = target
					print(repair_turn_value)
					break
		
		if (attack_turn_value == 0 and building_turn_value == 0 and repair_turn_value == 0):
			pass
		# MOVE
		# if no targets
		# define a direction to move to 
		# - general area
		# - closest building or enemy unit
		
		# CALCULATE BEST TURN VALUE and execute action
		if attack_turn_value > repair_turn_value and attack_turn_value > building_turn_value:
			pass # move near and attack
		elif building_turn_value >= attack_turn_value and building_turn_value > repair_turn_value:
			pass # move to building and capture
		elif repair_turn_value >= building_turn_value and repair_turn_value >= attack_turn_value:
			pass # move to building and pass
	for building in team.buildings:
		if building.type != gl.BUILDINGS.RUINS or building.type != gl.BUILDINGS.RUINS_2:
			signals.emit_signal("unit_added", gl.UNITS.LIGHT_INFANTRY, team, building.position)
		# build unit according to map type, starting from most expensive and then creating basic units
		# or fill all buildings with units
		pass
pass
