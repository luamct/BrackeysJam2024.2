extends Node

# Auto-loaded singleton that stores the persistent 
# state of the game, and also the levels configuration

@export var starting_health: int
@export var starting_engine_power: int
@export var starting_currency: int
@export var levels: Array[LevelConfigResource]

var max_health: int
var engine_power: int
var currency: int
var fire_rates: Dictionary  # Fire rates for each machine gun module
var total_fire_power: float = 0

var current_level = 0
var grid: Dictionary

func _ready():
	reset()
	
func current_level_config() -> LevelConfigResource:
	return levels[current_level]

func no_next_level() -> bool:
	return current_level == levels.size()

func add_module(module: ModuleResource, coords: Vector2i):
	grid[coords] = module

	var boost = 0.5
	match module.name:
		"MachineGun":
			fire_rates[coords] = module.fire_rate / (1 + boost_from_lub_tanks(coords))
			total_fire_power += module.damage / fire_rates[coords]

		"Armor":
			max_health += module.extra_health * (1 + boost_from_lub_tanks(coords))

		"EngineBlock":
			engine_power += module.engine_power * (1 + boost_from_lub_tanks(coords))
			
		"LubTank":
			check_neighboors(coords + Vector2i.UP, boost)
			check_neighboors(coords + Vector2i.DOWN, boost)
			check_neighboors(coords + Vector2i.LEFT, boost)
			check_neighboors(coords + Vector2i.RIGHT, boost)

func boost_from_lub_tanks(coords: Vector2i) -> float:
	return (
		is_lub_tank(coords + Vector2i.UP) +
		is_lub_tank(coords + Vector2i.DOWN) +
		is_lub_tank(coords + Vector2i.LEFT) +
		is_lub_tank(coords + Vector2i.RIGHT)
	) * 0.5

func is_lub_tank(coords: Vector2i) -> float:
	var module = grid.get(coords)
	return float(module != null and module.name == "LubTank")

func check_neighboors(coords: Vector2i, boost: float):
	var module = grid.get(coords)
	if module == null:
		return

	match module.name:
		"MachineGun":
			total_fire_power -= module.damage / fire_rates[coords]
			fire_rates[coords] /= 1 + boost
			total_fire_power += module.damage / fire_rates[coords]

		"Armor":
			max_health += module.extra_health * boost

		"EngineBlock":
			engine_power += module.engine_power * boost

func reset():
	max_health = starting_health
	engine_power = starting_engine_power
	currency = starting_currency
	current_level = 0
	grid.clear()
