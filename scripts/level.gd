class_name Level
extends Node2D

const SOURCE_ID = 0
const SAND_TILE_COORD = Vector2i(0, 0)
const STORM_TILE_COORD = Vector2i(1, 0)
const MOUNTAIN_TILE_COORD = Vector2i(2, 0)
const START_TILE_COORD = Vector2i(3, 0)
const GOAL_TILE_COORD = Vector2i(4, 0)
const LING = preload("res://scenes/enemies/ling.tscn")
const BRUTE = preload("res://scenes/enemies/brute.tscn")

const types_to_tiles = {
	LevelAreaResource.AreaType.SAND: SAND_TILE_COORD,
	LevelAreaResource.AreaType.STORM: STORM_TILE_COORD,
	LevelAreaResource.AreaType.START: START_TILE_COORD,
	LevelAreaResource.AreaType.GOAL: GOAL_TILE_COORD,
}

# Enemy logic
@export var enemy_noise: NoiseTexture2D
var enemy_mobs_size: float = -0.3     # The lower, the smaller the mobs, limits -0.6, 0.6
var enemy_mobs_density: float = 0.02  # The lower, the lower the density of mobs, limits (0, 1)
var brute_probability: float = 0.2

var enemies: Array[Enemy]

@onready var vehicle: Vehicle = $Vehicle
@onready var health_bar: ProgressBar = %HealthBar
@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var goal_area: Area2D = $GoalArea
@onready var currency_label: Label = %CurrencyLabel
@onready var tile_size: int = tile_map.tile_set.tile_size.x
@onready var garage_scene: PackedScene = load("res://scenes/garage.tscn")
@onready var victory_scene: PackedScene = load("res://scenes/victory.tscn")

var level_config: LevelConfigResource

func _ready():
	level_config = Globals.current_level_config()
	
	vehicle.health_changed.connect(on_health_changed)
	health_bar.value = 1.0
	currency_label.text = str(Globals.currency)

	@warning_ignore("integer_division")
	var half_height = level_config.height/2
	var starting_x = 0
	for level_area: LevelAreaResource in level_config.areas:
		if level_area.type == LevelAreaResource.AreaType.GOAL:
			goal_area.global_position.x = starting_x * tile_size

		for y in range(-half_height, half_height):
			for x in range(level_area.length):
				tile_map.set_cell(Vector2i(starting_x + x, y), SOURCE_ID, types_to_tiles[level_area.type])

		starting_x += level_area.length

	goal_area.body_entered.connect(on_body_entered_goal_area)
	
	place_enemies()

func place_enemies():
	var height = level_config.height
	var length = level_config.areas.reduce(func(total_length, a): return a.length + total_length, 0)
	enemy_noise.height = height
	enemy_noise.width = length
	enemy_noise.noise.frequency = enemy_mobs_density
	
	print(length, " x ", height)

	# Noise values, just for statisticsn on the range
	var values = []
	
	var starting_x = 0
	for area in level_config.areas:
		if area.type == LevelAreaResource.AreaType.STORM:
			for area_x in area.length:
				for y in height:
					var x = starting_x + area_x
					var value = enemy_noise.noise.get_noise_2d(x, y)
					values.append(value)

					if value < enemy_mobs_size:
						var enemy = null
						if randf() < brute_probability:
							enemy = BRUTE.instantiate()
						else:
							enemy =  LING.instantiate()
							
						enemy.position = Vector2(x, y) * tile_size
						enemy.death.connect(on_enemy_died)
						add_child(enemy)
						
						enemies.append(enemy)

		starting_x += area.length

			
	print("Total enemies added: ", enemies.size())
	print("Noise range: (%f, %f)" % [values.min(), values.max()])
	

func on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)

func on_body_entered_goal_area(body: Node2D):
	if body is Vehicle:
		vehicle.disable_controls()
		
		Globals.currency += level_config.reward
		currency_label.text = str(Globals.currency)
		Globals.current_level += 1
		
		await get_tree().create_timer(2.0).timeout
		if Globals.no_next_level():
			#Add Victory screen!
			get_tree().change_scene_to_packed(victory_scene)
			#get_tree().quit()
			
		call_deferred("load_garage_scene")

func load_garage_scene():
	get_tree().change_scene_to_packed(garage_scene)
	
func on_health_changed(percentage: float):
	health_bar.value = percentage
