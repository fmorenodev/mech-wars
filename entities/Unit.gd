extends Path2D

tool
class_name Unit

onready var UnitSprite: AnimatedSprite = $PathFollow2D/AnimatedSprite
onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
onready var PathF: PathFollow2D = $PathFollow2D
onready var HealthLabel: Label = $PathFollow2D/AnimatedSprite/HealthLabel
onready var AuxLabel: Label = $PathFollow2D/AnimatedSprite/AuxLabel

var unit_data = gl.units

export var id: int
var unit_name: String
var movement: int
var health: float = 10.0 setget set_health
var energy: int
var ammo: int
var move_type: int
var atk_type: int
var w1_dmg_chart: Dictionary
var w2_dmg_chart: Dictionary
var cost: int
var can_capture: bool
var team: int setget set_team

# change during play
var capture_points: int = 0
var atk_bonus = 1
var def_bonus = 1
var current_energy_cost: int = 0
var rounded_health: int = 10

# variables for movement
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

# TODO: bonus to incentivice certain actions, not implemented
var stay_in_place_bonus: float
var choose_diff_pos_bonus: float

func set_health(value: float) -> void:
	health = value
	if health <= 0:
		health = 0
		signals.emit_signal("unit_deleted", self)
		return
	elif health > 10:
		health = 10
	var label_value = round_health(health)
	rounded_health = label_value
	if label_value < 10:
		HealthLabel.text = str(label_value)
	elif label_value == 10:
		HealthLabel.text = ''

func round_health(value: float) -> float:
	return abs(ceil(value))

func set_texture(value: SpriteFrames) -> void:
	texture = value
	if not UnitSprite:
		yield(self, "ready")
	UnitSprite.frames = value

func set_is_moving(value: bool) -> void:
	is_moving = value
	set_process(is_moving)

func set_team(value: int) -> void:
	team = value
	set_texture(sp.get_sprite(id))
	UnitSprite.animation = "idle"
	match value:
		gl.TEAM.RED:
			UnitSprite.material = sp.swap_mat

func initialize(unit: int) -> void:
	id = unit
	unit_name = gl.units[unit].unit_name
	movement = gl.units[unit].movement
	energy = gl.units[unit].energy
	ammo = gl.units[unit].ammo
	move_type = gl.units[unit].move_type
	w1_dmg_chart = gl.units[unit].w1_dmg_chart
	w2_dmg_chart = gl.units[unit].w2_dmg_chart
	atk_type = gl.units[unit].atk_type
	cost = gl.units[unit].cost
	can_capture = gl.units[unit].can_capture

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
	if team == gl.TEAM.RED:
		UnitSprite.material = sp.swap_mat
	elif team == gl.TEAM.BLUE:
		UnitSprite.material = null

func end_turn() -> void:
	can_move = false
	UnitSprite.play()
	change_material_to_color()

func activate() -> void:
	atk_bonus = 1
	def_bonus = 1
	can_move = true
	change_material_to_color()

func capture() -> void:
	capture_points += int(ceil(health))
	if capture_points >= 20:
		AuxLabel.text = ''
	else:
		AuxLabel.text = 'c'
