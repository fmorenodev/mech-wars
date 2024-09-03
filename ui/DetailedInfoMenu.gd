extends PopupPanel

onready var building_texture: SpriteFrames = load("res://assets/map/individual_buildings.tres")
onready var tileset_texture: SpriteFrames = load("res://assets/map/green_tileset_individual.tres")
onready var none_texture = load("res://assets/gui/red_x.png")

onready var Main = get_node("/root/Main")

onready var UnitName = $HBoxContainer/UnitInfo/UnitStats/VBoxContainer/Name
onready var UnitDesc = $HBoxContainer/UnitInfo/UnitDesc
onready var UnitSprite = $HBoxContainer/UnitInfo/UnitStats/VBoxContainer/UnitSprite
onready var UnitMovement = $HBoxContainer/UnitInfo/UnitStats/VBoxContainer2/Movement
onready var UnitWeapon1 = $HBoxContainer/UnitInfo/WeaponsInfo/HBoxContainer/Weapon1
onready var UnitWeapon2 = $HBoxContainer/UnitInfo/WeaponsInfo/Weapon2
onready var UnitAmmo = $HBoxContainer/UnitInfo/WeaponsInfo/HBoxContainer/Ammo
onready var UnitEnergy = $HBoxContainer/UnitInfo/UnitStats/VBoxContainer2/Energy
onready var UnitWeapon1Info = $HBoxContainer/UnitInfo/WeaponsInfo/Weapon1Info
onready var UnitWeapon2Info = $HBoxContainer/UnitInfo/WeaponsInfo/Weapon2Info
onready var UnitInfoContainer = $HBoxContainer/UnitInfo

onready var TileName = $HBoxContainer/DetailedTileInfo/HBoxContainer/VBoxContainer/Name
onready var TileSprite = $HBoxContainer/DetailedTileInfo/HBoxContainer/VBoxContainer/TileSprite
onready var TileFunds = $HBoxContainer/DetailedTileInfo/HBoxContainer/VBoxContainer2/Funds
onready var TileRepair = $HBoxContainer/DetailedTileInfo/HBoxContainer/VBoxContainer2/Repair
onready var TileDesc = $HBoxContainer/DetailedTileInfo/Desc
onready var TerrainStars = $HBoxContainer/DetailedTileInfo/TerrainStars
onready var MovementTitle = $HBoxContainer/DetailedTileInfo/Movement/Title
onready var MovementInfo = $HBoxContainer/DetailedTileInfo/Movement/Info

func _ready():
	var _err = signals.connect("open_detailed_info_menu", self, "_on_open_detailed_info_menu")
	MovementTitle.text = tr('TERRAIN_MOVE_TITLE')

func _on_open_detailed_info_menu(pos: Vector2) -> void:
	self.popup()
	var tile_id = Main.TerrainTileMap.get_cellv(pos)
	var unit = Main.is_unit_in_position(pos)
	var building = Main.is_building_in_position(pos)
	if unit:
		UnitName.text = gl.units[unit.id].unit_name
		UnitDesc.text = gl.units[unit.id].desc
		UnitSprite.texture = unit.texture.get_frame('idle', 0)
		if unit.team == gl.TEAM.RED:
			UnitSprite.material = sp.swap_mat
		else:
			UnitSprite.material = null
		UnitMovement.text = "%s: %s" % [tr('MOVE'), str(unit.movement)]
		UnitWeapon1.text = gl.units[unit.id].weapon_1
		UnitWeapon2.text = gl.units[unit.id].weapon_2
		if gl.units[unit.id].weapon_1 != tr('NONE'):
			UnitAmmo.text = "%s / %s %s" % [str(unit.ammo), str(gl.units[unit.id].ammo), tr('AMMO')]
		else:
			UnitAmmo.text = ''
		UnitEnergy.text = "%s: %s / %s" % [tr('ENERGY'), str(unit.energy), str(gl.units[unit.id].energy)]
		
		for child in UnitWeapon1Info.get_children():
			UnitWeapon1Info.remove_child(child)
			child.queue_free()
		for child in UnitWeapon2Info.get_children():
			UnitWeapon2Info.remove_child(child)
			child.queue_free()
		if gl.units[unit.id].weapon_1 != tr('NONE'):
			for can_attack in unit.w1_can_attack:
				var trec_node = TextureRect.new()
				trec_node.texture = sp.sprites[can_attack].get_frame('idle', 0)
				UnitWeapon1Info.add_child(trec_node)
		else:
			var trec_node = TextureRect.new()
			trec_node.texture = none_texture
			UnitWeapon1Info.add_child(trec_node)
		if gl.units[unit.id].weapon_2 != tr('NONE'):
			for can_attack in unit.w2_can_attack:
				var trec_node = TextureRect.new()
				trec_node.texture = sp.sprites[can_attack].get_frame('idle', 0)
				UnitWeapon2Info.add_child(trec_node)
		else:
			var trec_node = TextureRect.new()
			trec_node.texture = none_texture
			UnitWeapon2Info.add_child(trec_node)
		UnitInfoContainer.visible = true
	else:
		UnitInfoContainer.visible = false
	
	if building:
		TileName.text = gl.buildings[building.type].name
		TileSprite.texture = building_texture.get_frame(str(building.team), building.type)
		TileDesc.text = gl.buildings[building.type].desc
		TileFunds.text = '%s: %s' % [tr('FUNDS'), building.funds]
		var can_repair: String
		var building_data = gl.buildings[building.type].repairs
		if building_data.has(gl.MOVE_TYPE.AIR):
			can_repair = tr('AIR_MOVE')
		if building_data.has(gl.MOVE_TYPE.WATER):
			can_repair = tr('WATER_MOVE')
		if building_data.has(gl.MOVE_TYPE.INFANTRY):
			can_repair = tr('LAND')
		else:
			can_repair = tr('NONE')
		TileRepair.text = '%s: %s' % [tr('CAN_REPAIR'), can_repair]
	else:
		TileName.text = gl.terrain[tile_id].name
		TileSprite.texture = tileset_texture.get_frame('default', tile_id)
		TileDesc.text = gl.terrain[tile_id].desc
		TileFunds.text = ''
		TileRepair.text = ''
	
	for child in MovementInfo.get_children():
		MovementInfo.remove_child(child)
		child.queue_free()
	for key in gl.terrain[tile_id].move_values:
		if gl.terrain[tile_id].move_values[key] < 99:
			var trec_node = Label.new()
			trec_node.text = '%s: %s' % [gl.move_types[key].name, str(gl.terrain[tile_id].move_values[key])]
			MovementInfo.add_child(trec_node)
	
	var stars = Main.get_terrain_stars(Main.TerrainTileMap.map_to_world(pos))
	TerrainStars.value = stars
	if stars < 0:
		TerrainStars.value = -stars
		TerrainStars.tint_progress = Color('7e1c1c')
	else:
		TerrainStars.tint_progress = Color('ffffff')
