extends VBoxContainer

onready var building_texture: SpriteFrames = load("res://assets/map/individual_buildings.tres")
onready var tileset_texture: SpriteFrames = load("res://assets/map/green_tileset_individual.tres")

onready var Main = get_node("/root/Main")
onready var EntityName = $PanelContainer/HBoxContainer/EntityInfo/EntityName
onready var EntitySprite = $PanelContainer/HBoxContainer/EntityInfo/EntitySprite
onready var EntityHealth = $PanelContainer/HBoxContainer/EntityInfo/VBoxContainer/Health/Label
onready var EntityAmmoContainer = $PanelContainer/HBoxContainer/EntityInfo/VBoxContainer/Ammo
onready var EntityAmmo = $PanelContainer/HBoxContainer/EntityInfo/VBoxContainer/Ammo/Label
onready var EntityEnergy = $PanelContainer/HBoxContainer/EntityInfo/VBoxContainer/Energy/Label
onready var UnitInfoContainer = $PanelContainer/HBoxContainer/EntityInfo

onready var EntityName2 = $PanelContainer/HBoxContainer/EntityInfo2/EntityName
onready var EntitySprite2 = $PanelContainer/HBoxContainer/EntityInfo2/EntitySprite
onready var TerrainStars = $PanelContainer/HBoxContainer/EntityInfo2/TextureProgress
onready var TileCaptureContainer = $PanelContainer/HBoxContainer/EntityInfo2/CapturePoints
onready var TileCapturePoints = $PanelContainer/HBoxContainer/EntityInfo2/CapturePoints/Label

onready var DamagePreview = $DamagePreview
onready var DamagePreviewNumber = $DamagePreview/VBoxContainer/Gradient/Percent
onready var DamagePreviewGradientColors = $DamagePreview/VBoxContainer/Gradient.texture.gradient

var unit

func _ready():
	var _err = signals.connect("cursor_moved", self, "_on_cursor_moved")
	_err = signals.connect("attack_action", self, "_on_attack_action")
	_err = signals.connect("target_selected", self, "_on_target_selected")
	_err = signals.connect("cancel_pressed", self, "_on_cancel_pressed")
	$DamagePreview/VBoxContainer/Label.text = tr('DAMAGE')

func _on_cursor_moved(pos: Vector2) -> void:
	var tile_id = Main.TerrainTileMap.get_cellv(pos)
	unit = Main.is_unit_in_position(pos)
	var building = Main.is_building_in_position(pos)
	if unit:
		EntityName.text = gl.units[unit.id].unit_name
		EntitySprite.texture = unit.texture.get_frame('idle', 0)
		if unit.team_id == gl.TEAM.RED:
			EntitySprite.material = sp.swap_mat
		else:
			EntitySprite.material = null
		EntityHealth.text = str(unit.rounded_health)
		if unit.ammo == -1:
			EntityAmmo.text = tr("INFINITE")
		else:
			EntityAmmo.text = str(unit.ammo)
		EntityEnergy.text = str(unit.energy)
		UnitInfoContainer.visible = true
	else:
		UnitInfoContainer.visible = false
		
	if building:
		EntityName2.text = gl.buildings[building.type].name
		EntitySprite2.texture = building_texture.get_frame(str(building.team_id), building.type)
		if unit:
			TileCapturePoints.text = str(20 - unit.capture_points)
		else:
			TileCapturePoints.text = '20'
		TileCaptureContainer.visible = true
	else:
		EntityName2.text = gl.terrain[tile_id].name
		EntitySprite2.texture = tileset_texture.get_frame('default', tile_id)
		TileCaptureContainer.visible = false
	var stars = Main.get_terrain_stars(Main.TerrainTileMap.map_to_world(pos))
	TerrainStars.value = stars
	if stars < 0:
		TerrainStars.value = -stars
		TerrainStars.tint_progress = Color('7e1c1c')
	else:
		TerrainStars.tint_progress = Color('ffffff')
	calc_damage_preview()

func calc_damage_preview() -> void:
	if unit and Main.active_unit:
		if unit != Main.active_unit:
			var damage = Main.calc_damage(Main.active_unit, unit, false)
			DamagePreviewNumber.text = '%s %%' % str(damage * 10)
			var counter_damage = Main.calc_retaliation_damage(unit, Main.active_unit, damage, false)
			var combat_result = damage - counter_damage
			if combat_result <= -5:
				DamagePreviewGradientColors.set_color(0, Color('d82f2f'))
				DamagePreviewGradientColors.set_color(1, Color('a95d5d'))
			elif combat_result >= 5:
				DamagePreviewGradientColors.set_color(0, Color('33dcbc'))
				DamagePreviewGradientColors.set_color(1, Color('ddfffc'))
			elif combat_result >= 2:
				DamagePreviewGradientColors.set_color(0, Color('23df40'))
				DamagePreviewGradientColors.set_color(1, Color('c5ffcd'))
			elif combat_result <= -2:
				DamagePreviewGradientColors.set_color(0, Color('eb942f'))
				DamagePreviewGradientColors.set_color(1, Color('fed3a1'))
			elif combat_result >= -2 or combat_result <= 2:
				DamagePreviewGradientColors.set_color(0, Color('f6e132'))
				DamagePreviewGradientColors.set_color(1, Color('fff180'))

func _on_attack_action() -> void:
	DamagePreview.visible = true

func _on_target_selected(_pos: Vector2) -> void:
	DamagePreview.visible = false

func _on_cancel_pressed() -> void:
	DamagePreview.visible = false

func _on_mouse_entered():
	if get_anchor(MARGIN_LEFT) == 0:
		set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT, 3)
	else:
		set_anchors_and_margins_preset(Control.PRESET_BOTTOM_LEFT, 3)
