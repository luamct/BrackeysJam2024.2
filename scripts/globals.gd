extends Node

# Auto-loaded singleton that stores the persistent 
# state of the game, and also the levels configuration

@export var max_health: int
@export var engine_power: int
@export var currency: int
@export var levels: Array[LevelConfigResource]

var current_level = 0
var grid: Dictionary

func current_level_config() -> LevelConfigResource:
	return levels[current_level]

func no_next_level() -> bool:
	return current_level == levels.size()

func add_module(module: ModuleResource, coords: Vector2i):
	grid[coords] = module

	match module.name:
		"MachineGun":
			pass # Nothing to change here, only in the vehicle

		"Armor":
			max_health += module.extra_health
			
		"EngineBlock":
			engine_power += module.engine_power
