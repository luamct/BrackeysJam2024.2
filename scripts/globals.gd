extends Node

# Auto-loaded singleton that stores the persistent 
# state of the game, and also the levels configuration

@export var levels: Array[LevelConfigResource]

var current_level = 0
var currency: int = 5
var grid: Dictionary

func current_level_config() -> LevelConfigResource:
	return levels[current_level]

func no_next_level() -> bool:
	return current_level == levels.size()
