extends Path2D

tool
class_name Unit

onready var UnitSprite: AnimatedSprite = $PathFollow2D/AnimatedSprite
onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
onready var PathF: PathFollow2D = $PathFollow2D
onready var HealthLabel: Label = $PathFollow2D/AnimatedSprite/HealthLabel
onready var AuxLabel: Label = $PathFollow2D/AnimatedSprite/AuxLabel

onready var greyscale_mat: Material = preload("res://assets/greyscale_material.tres")

var id: int
var unit_name: String
var movement: int
var health: int = 10 setget set_health
var energy: int
var move_type: int
var atk_type: int
var dmg_chart: Dictionary
var cost: int

var team: int setget set_team
var capture_points: int = 0

signal walk_finished
var texture: SpriteFrames setget set_texture
var move_sound
var move_speed := 150.0
var is_moving := false setget set_is_moving
var is_selected := false
var can_move := false
var last_pos: Vector2

func set_health(value: int) -> void:
	health = value
	if health <= 0:
		health = 0
		signals.emit_signal("unit_deleted", self)
		return
	elif health > 10:
		health = 10
	var label_value = round_health(health)
	if label_value < 10:
		HealthLabel.text = str(label_value)
	elif label_value == 10:
		HealthLabel.text = ''

func round_health(value: float) -> float:
	return abs(round(value))

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
	match value:
		gl.TEAM.RED:
			UnitSprite.animation = "red"
		gl.TEAM.BLUE:
			UnitSprite.animation = "blue"

func initialize(unit: int) -> void:
	match unit:
		gl.UNITS.LIGHT_INFANTRY:
			id = gl.UNITS.LIGHT_INFANTRY
			unit_name = 'Infantry'
			movement = 4
			energy = 99
			move_type = gl.MOVE_TYPE.LIGHT_INF
			dmg_chart = {gl.UNITS.LIGHT_INFANTRY: 55, gl.UNITS.ARTILLERY: 15}
			atk_type = gl.ATTACK_TYPE.DIRECT
			cost = 1000
		gl.UNITS.ARTILLERY:
			id = gl.UNITS.ARTILLERY
			unit_name = 'Artillery'
			movement = 6
			energy = 99
			move_type = gl.MOVE_TYPE.ARTILLERY
			dmg_chart = {gl.UNITS.LIGHT_INFANTRY: 90, gl.UNITS.ARTILLERY: 75}
			atk_type = gl.ATTACK_TYPE.ARTILLERY
			cost = 6000

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
	UnitSprite.material = greyscale_mat

func end_turn() -> void:
	can_move = false
	UnitSprite.play()
	UnitSprite.material = null

func activate() -> void:
	can_move = true

func capture() -> void:
	capture_points += health
	if capture_points >= 20:
		AuxLabel.text = ''
	else:
		AuxLabel.text = 'c'
