# mech-wars
advance wars clone with futuristic setting

credits:
* font used: Fipps by pheist @ https://pheist.net/fonts.php?id=51
* palette swap shader by KoBeWi @ https://github.com/KoBeWi/Godot-Palette-Swap-Shader

## TODO_LIST:
- ~~basic units~~
- ~~basic terrain~~
- ~~basic mechanics:~~
	- ~~movement~~
	- ~~combat~~
	- ~~capturing~~
- ~~basic menus~~
- ~~turn cycle~~
- ~~functional buildings:~~
	- ~~unit production~~
	- ~~repairing~~
- basic AI:
	- units
		- ~~attack~~
		- ~~capture~~
		- ~~repair~~
		- ~~move~~
		- ~~turn conflicts, recalculation~~
		- ~~make moves not simultaneous~~
	- buildings
		- unit creation
		- optimal creation
- ~~adding more units~~
- ~~adding more terrain and making it functional (bonuses, movement types for different units)~~
- ~~adding UI~~
- ~~adding ammo, weapon and energy mechanics~~
- ~~adding damage preview for combat~~
- ~~adding COs~~
- ~~adding powers~~
	- ~~power bar and power bar mechanics~~
	- ~~AI can use powers~~
- ~~adding victory and defeat~~
- ~~adding surrender~~
- add testing utilities and ~~change initialization for units and buildings~~
- adding building mechanics (research, power plant)
- adding other mechanics (unit merging, etc)
- adding all the missing units
- making a playable map
- adding sounds
- adding factions
- ui overhaul
- demo?
- advanced AI
- adding more animations
- title screen, options, saving
- campaign / normal maps
- fog (see how much time it takes)

## KNOWN BUGS
- ai units sometimes move to another unit's space (unknown cause, unsure if solved)
- indirect units sometimes can attack after moving (unknown cause)
- can select empty target when attacking (unsure if solved)

## IDEAS

story: the human race was wiped of the face of the earth, now their creations wage war following their old orders. Some of them have manage to evolve and become sentient
and are trying to overrun all other or create a peaceful society.
The protag has the ability to "infect" other mechs and control them or turn them hostile. Some of the "enemies" you encounter are not really enemies, their mechs just attack you because of this.
- there are some surviving humans: 
	- One is the main antagonist, which has created the protagonist. Wants to kill the surviving humans so he is the only human alive, and seeks world domination. Knows how to create sentient robots.
	- Another one is trying to find other humans and stumbles into the protag, and the protag offers to help him.
There could be rumours of a real or fake place with humans still alive, could be the lair of the villain.

COs: 
- protag: Mark-0 "Polo" an advanced mech with a good natured ai that is programmed to scout the world. In reality, he is a sleeper agent, and will be activated when he locates enough humans.
	It has the capacity to take control of battle mechs, but won't show it until he is activated by his master.
	day-to-day: recons have +20% atk
	powers: - Scouting Mission: +1 movement to all units, recons have +40% atk
			- Target Located: +2 movement to all units, recons have +40% atk and attack like tanks for a turn.
	design: sleek android with a kind face, designed for speed and evasion

- first enemy co: B.A.N.D.I.T. (Big Android Nuisance Designed Incredibly Thick). A first generation android, built when the technology was still new. As a result, he is a low-ranked CO, having only mastered infantry tactics
	day-to-day: -10% def to all units except infantry, who have 10% atk and def boost.
	powers: - Moment of Insight: All units gain +20% atk and def
			- A Broken Clock...: All units gain + 30% atk and def, +1 movement
	design: old blocky huge android, not very human-like.
	
- human ally CO: a human mark-0 encounters on one of his scouting trips. Is looking for survivors to make a human colony, to make humanity's survival possible. Has fought countless mechs to get to where he is now, and has become very proficient in repairs.
	day-to-day: vehicle-type mechs get +20% atk and +10% def. Other mechs get -10% atk.
	powers: - Fight On: Repairs all units by 2 HP
			- Beacon of Hope: Repairs all units by 3 HP and gives 20% atk and def
	design: a young man with an overcoat full of grease and some kind of big tool (older Andy???)

- evil mark-0: controlado por su creador, es una máquina despiadada de matar.
	day-to-day: 30% atk bonus
	powers: - Die By My Hand: +1 movement, +20% atk and def
			- Absolute Control: Take control of two enemy units / choose 4 and be given 2 at random (for one turn)
	design: like the normal version, but with more edges and weaponry, and a red light instead of the normal blue

- final boss CO: 
	day-to-day: units have 11 or 12 base hp
	powers: - Humanity's Bane: lowers the max HP of enemy units by 1 for the rest of the match
			- Will of the Machine Lord: choose a superpower between all / the android COs ???
	design: an old but bulky cyborg, dressed with tight clothes and a military cut, with arms crossed and standing with his chest puffed.

possible mechanics:
- unit evolution
- unit merging makes a different unit or a more powerful version
- unit producing buildings give less funds?
- ability to redo missions
- upgrades in the campaign mode via spending funds or finding upgrades in buildings
- power plants fill power meter faster
- secondary objectives in maps
- secret objectives?
- unit limit (units have point values)
- modify unit limit by capturing

Units:
- Faster and more expensive infantry?
- Amphibian / flying infantry?

CO designs:
- human / cyborg CO with special units?
- infantry CO with special unit / stronger bonuses from research ruins 
