extends HBoxContainer

onready var building_texture: SpriteFrames = load("res://assets/map/individual_buildings.tres")
onready var tileset_texture: SpriteFrames = load("res://assets/map/green_tileset_individual.tres")

onready var Main = get_node("/root/Main")
onready var EntityName = $EntityInfo/EntityName
onready var EntitySprite = $EntityInfo/EntitySprite
onready var EntityAmmo = $EntityInfo/HBoxContainer/Ammo/Label
onready var EntityEnergy = $EntityInfo/HBoxContainer/Energy/Label
onready var UnitInfoContainer = $EntityInfo

onready var EntityName2 = $EntityInfo2/EntityName
onready var EntitySprite2 = $EntityInfo2/EntitySprite
onready var TerrainStars = $EntityInfo2/TextureProgress

func _ready():
	var _err = signals.connect("cursor_moved", self, "_on_cursor_moved")

func _on_cursor_moved(pos: Vector2) -> void:
	var tile_id = Main.TerrainTileMap.get_cellv(pos)
	var unit = Main.is_unit_in_position(pos)
	var building = Main.is_building_in_position(pos)
	if unit:
		EntityName.text = gl.units[unit.id].unit_name
		EntitySprite.texture = unit.texture.get_frame('idle', 0)
		if unit.team == gl.TEAM.RED:
			EntitySprite.material = sp.swap_mat
		else:
			EntitySprite.material = null
		EntityAmmo.text = str(unit.ammo)
		EntityEnergy.text = str(unit.energy)
		UnitInfoContainer.visible = true
	else:
		UnitInfoContainer.visible = false
		
	if building:
		EntityName2.text = gl.buildings[building.type].name
		EntitySprite2.texture = building_texture.get_frame(str(building.team), building.type)
	else:
		EntityName2.text = gl.terrain[tile_id].name
		EntitySprite2.texture = tileset_texture.get_frame('default', tile_id)
	var stars = Main.get_terrain_stars(Main.TerrainTileMap.map_to_world(pos))
	TerrainStars.value = stars
	if stars < 0:
		TerrainStars.value = -stars
		TerrainStars.tint_progress = Color('7e1c1c')
	else:
		TerrainStars.tint_progress = Color('ffffff')
