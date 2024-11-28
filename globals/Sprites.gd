extends Node

# TODO: add new sprites for the new units

const light_inf = preload("res://assets/units/light_infantry/light_infantry.tres")
const heavy_inf = preload("res://assets/units/heavy_infantry/heavy_infantry.tres")
const flying_infantry = preload("res://assets/units/flying_infantry/flying_infantry.tres")
const support_mech = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const recon = preload("res://assets/units/recon/recon.tres")
const light_tank = preload("res://assets/units/light_tank/light_tank.tres")
const medium_tank = preload("res://assets/units/medium_tank/medium_tank.tres")
const anti_air = preload("res://assets/units/anti_air/anti_air.tres")
# const artillery = preload("res://assets/units/artillery/artillery.tres")
const artillery = preload("res://assets/units/artillery_v2/artillery_v2.tres")
const heavy_artillery = preload("res://assets/units/heavy_artillery/heavy_artillery.tres")
const arc_tower = preload("res://assets/units/arc_tower/arc_tower.tres")
const missile_launcher = preload("res://assets/units/missile_launcher/missile_launcher.tres")
const trans_drone = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const drone = preload("res://assets/units/drone/drone.tres")
const seaplane = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const sky_fortress = preload("res://assets/units/sky_fortress/sky_fortress.tres")
const angel = preload("res://assets/units/angel/angel.tres")
const gunboat = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const lander = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const cruiser = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const submarine = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE
const battleship = preload("res://assets/units/battleship/battleship.tres")
const carrier = preload("res://assets/units/artillery/artillery.tres") # TODO: CHANGE

const sprites := { gl.UNITS.LIGHT_INFANTRY: light_inf, gl.UNITS.HEAVY_INFANTRY: heavy_inf,
				gl.UNITS.FLYING_INFANTRY: flying_infantry, gl.UNITS.SUPPORT_MECH: support_mech,
				gl.UNITS.RECON: recon, gl.UNITS.LIGHT_TANK: light_tank, gl.UNITS.MEDIUM_TANK: medium_tank,
				gl.UNITS.ANTI_AIR: anti_air, gl.UNITS.ARTILLERY: artillery,
				gl.UNITS.HEAVY_ARTILLERY: heavy_artillery, gl.UNITS.ARC_TOWER: arc_tower,
				gl.UNITS.MISSILE_LAUNCHER: missile_launcher, gl.UNITS.TRANS_DRONE: trans_drone,
				gl.UNITS.DRONE: drone, gl.UNITS.SEAPLANE: seaplane, gl.UNITS.ANGEL: angel,
				gl.UNITS.SKY_FORTRESS: sky_fortress, gl.UNITS.GUNBOAT: gunboat,
				gl.UNITS.LANDER: lander, gl.UNITS.CRUISER: cruiser, gl.UNITS.SUBMARINE: submarine,
				gl.UNITS.BATTLESHIP: battleship, gl.UNITS.CARRIER: carrier}

const greyscale_mat: Material = preload("res://assets/shaders/materials/greyscale_material.tres")
const red_swap_mat: Material = preload("res://assets/shaders/materials/red_swap_material.tres")
const blue_swap_mat: Material = preload("res://assets/shaders/materials/blue_swap_material.tres")
const green_swap_mat: Material = preload("res://assets/shaders/materials/green_swap_material.tres")
const yellow_swap_mat: Material = preload("res://assets/shaders/materials/yellow_swap_material.tres")
const team_materials := {gl.TEAM.RED: red_swap_mat, gl.TEAM.BLUE: blue_swap_mat, gl.TEAM.GREEN: green_swap_mat, gl.TEAM.YELLOW: yellow_swap_mat}

const red_faction: Texture = preload("res://assets/gui/factions/red_faction.png")
const blue_faction: Texture = preload("res://assets/gui/factions/blue_faction.png")
const green_faction: Texture = preload("res://assets/gui/factions/green_faction.png")
const yellow_faction: Texture = preload("res://assets/gui/factions/yellow_faction.png")
const team_icons := {gl.TEAM.RED: red_faction, gl.TEAM.BLUE: blue_faction, gl.TEAM.GREEN: green_faction, gl.TEAM.YELLOW: yellow_faction}

const neutral_buildings: Texture = preload("res://assets/map/building_tileset.png")
const red_buildings: Texture = preload("res://assets/map/building_tileset_red.png")
const blue_buildings: Texture = preload("res://assets/map/building_tileset_blue.png")
const green_buildings: Texture = preload("res://assets/map/building_tileset_green.png")
const yellow_buildings: Texture = preload("res://assets/map/building_tileset_yellow.png")
const building_sprites := {-1: neutral_buildings, gl.TEAM.RED: red_buildings, gl.TEAM.BLUE: blue_buildings,
						gl.TEAM.GREEN: green_buildings, gl.TEAM.YELLOW: yellow_buildings}

func get_sprite(id: int) -> Resource:
	return sprites[id]

func get_building_sprite(id: int) -> Resource:
	return building_sprites[id]
