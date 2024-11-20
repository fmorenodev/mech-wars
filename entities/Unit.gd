extends Path2D

tool
class_name Unit

onready var UnitSprite: AnimatedSprite = $PathFollow2D/AnimatedSprite
onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
onready var PathF: PathFollow2D = $PathFollow2D
onready var HealthLabel: Label = $PathFollow2D/AnimatedSprite/HealthLabel
onready var AuxLabel: Label = $PathFollow2D/AnimatedSprite/AuxLabel
onready var AuxTexture: TextureRect = $PathFollow2D/AnimatedSprite/AuxTexture

export var id: int
export var team_id: int setget set_team
var allegiance: int
var unit_name: String
var movement: int
var health := 10.0 setget set_health
var max_health := 10.0 setget set_max_health
var energy: int
var ammo: int
var move_type: int
var atk_type: int
var w1_dmg_chart: Dictionary
var w2_dmg_chart: Dictionary
var w1_can_attack: Array
var w2_can_attack: Array
var cost: int
var point_cost: int
var can_capture: bool
var lifesteal := 0.0 # % of damage healed
var fund_salvaging := 0.0 # % of damage gained as funds

# CO variables
var co: int setget set_co
var atk_mod := 1.0
var def_mod := 1.0
var cap_mod := 1.0

# other variables
var capture_points := 0
var capturing_building
var current_energy_cost := 0
var rounded_health := 10
var joined_this_turn := false # if unit used join action

# resets at start of turn
var atk_bonus := 1.0
var def_bonus := 1.0

# movement animation variables
signal walk_finished
var texture: SpriteFrames setget set_texture
var move_sound
var move_speed := 150.0
var is_moving := false setget set_is_moving
var is_selected := false
var can_move := false
var last_pos # Vector2 or null

# turn values to decide turn actions
var attack_turn_value: float
var chosen_target
var cell_to_move

var capture_turn_value: float
var chosen_capture_building

var repair_turn_value: float
var chosen_repair_building

var move_path: Array

var chosen_action: Array

func set_health(value: float) -> void:
	health = value
	if health <= 0:
		health = 0
		signals.emit_signal("unit_deleted", self)
		return
	elif health > max_health:
		health = max_health
	var label_value = round_health(health)
	rounded_health = label_value
	if (co == gl.COS.BOSS and label_value < 12) or (co != gl.COS.BOSS and label_value < 10):
		HealthLabel.text = str(label_value)
	elif (co == gl.COS.BOSS and label_value == 12) or (co != gl.COS.BOSS and label_value == 10):
		HealthLabel.text = ''

func set_max_health(value: float) -> void:
	max_health = value
	set_health(max_health)

func round_health(value: float) -> float:
	return abs(ceil(value))

func set_texture(value: SpriteFrames) -> void:
	texture = value
	if not UnitSprite:
		yield(self, "ready")
	UnitSprite.frames = value

func set_aux_texture(value) -> void:
	AuxTexture.texture = value

func set_is_moving(value: bool) -> void:
	is_moving = value
	set_process(is_moving)

func set_team(value: int) -> void:
	team_id = value
	set_texture(sp.get_sprite(id))

func set_co(value: int) -> void:
	co = value
	if (gl.co_data[co].unit_stats.keys().has(id)):
		atk_mod = gl.co_data[co].unit_stats[id].x
		def_mod = gl.co_data[co].unit_stats[id].y
		movement += gl.co_data[co].unit_stats[id].z
	else:
		atk_mod = 1.0
		def_mod = 1.0

func initialize(unit: int) -> void:
	id = unit
	var unit_data = gl.units[unit]
	unit_name = unit_data.unit_name
	movement = unit_data.movement
	energy = unit_data.energy
	ammo = unit_data.ammo
	move_type = unit_data.move_type
	w1_dmg_chart = unit_data.w1_dmg_chart
	w2_dmg_chart = unit_data.w2_dmg_chart
	w1_can_attack = unit_data.w1_can_attack
	w2_can_attack = unit_data.w2_can_attack
	atk_type = unit_data.atk_type
	cost = unit_data.cost
	point_cost = unit_data.point_cost
	can_capture = unit_data.can_capture

func _ready() -> void:
	set_process(false)
	if not Engine.editor_hint:
		curve = Curve2D.new()

func _process(delta: float) -> void:
	PathF.offset += move_speed * delta
	if PathF.unit_offset >= 1.0:
		self.is_moving = false
		PathF.offset = 0.0
		curve.clear_points()
		emit_signal("walk_finished")

# pass the coordinates from grid converted to world
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return
		
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(point - position)
	self.is_moving = true # start moving

func end_action() -> void:
	can_move = false
	UnitSprite.stop()
	UnitSprite.material = sp.greyscale_mat

func change_material_to_color() -> void:
	UnitSprite.material = sp.team_materials[team_id]

func end_turn() -> void:
	can_move = false
	UnitSprite.play()
	change_material_to_color()

func activate() -> void:
	atk_bonus = 1
	def_bonus = 1
	can_move = true
	change_material_to_color()

func capture(building) -> void:
	if !capturing_building:
		capturing_building = building
	elif capturing_building != building:
		capturing_building = building
		capture_points = 0
	capture_points += calc_next_cap_points()
	if capture_points >= 20:
		capturing_building = null
		AuxLabel.text = ''
	else:
		AuxLabel.text = 'c'

func calc_next_cap_points() -> int:
	return int(floor(ceil(health) * cap_mod))
