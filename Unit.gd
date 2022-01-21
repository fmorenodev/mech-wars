extends Path2D

tool
class_name Unit

onready var UnitSprite: AnimatedSprite = $PathFollow2D/AnimatedSprite
onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
onready var PathF: PathFollow2D = $PathFollow2D

var id: int
var unit_name: String
var movement: int
var energy: int
var move_type: int
var dmg_chart: Array

var team: int setget set_team

signal walk_finished
var texture: SpriteFrames setget set_texture
var move_sound
var move_speed := 100.0
var is_moving := false setget set_is_moving
var is_selected := false
var can_move := true

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
			movement = 4
			energy = 99
			move_type = gl.MOVE_TYPE.LIGHT_INF
			# dmg_chart

func _ready() -> void:
	set_process(false)
	if not Engine.editor_hint:
		curve = Curve2D.new()
	var _err = connect("walk_finished", self, "_on_walk_finished")

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

func _on_walk_finished() -> void:
	pass
