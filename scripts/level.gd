class_name Level
extends Node2D

const SOURCE_ID = 0
const SAND_TILE_COORD = Vector2i(0, 0)
const STORM_TILE_COORD = Vector2i(2, 0)
const MOUNTAIN_TILE_COORD = Vector2i(4, 0)
const START_TILE_COORD = Vector2i(6, 0)
const GOAL_TILE_COORD = Vector2i(8, 0)

const types_to_tiles = {
	LevelAreaResource.AreaType.SAND: SAND_TILE_COORD,
	LevelAreaResource.AreaType.STORM: STORM_TILE_COORD,
	LevelAreaResource.AreaType.START: START_TILE_COORD,
	LevelAreaResource.AreaType.GOAL: GOAL_TILE_COORD,
}

@onready var vehicle: Vehicle = $Vehicle
@onready var health_bar: ProgressBar = %HealthBar
@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var goal_area: Area2D = $GoalArea
@onready var currency_label: Label = %CurrencyLabel
@onready var tile_size: int = tile_map.tile_set.tile_size.x
@onready var garage_scene: PackedScene = load("res://scenes/garage.tscn")

@export var level_config: LevelConfigResource

func _ready():
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

func on_body_entered_goal_area(body: Node2D):
	if body is Vehicle:
		vehicle.disable_controls()
		Globals.currency += level_config.reward
		currency_label.text = str(Globals.currency)
		
		await get_tree().create_timer(2.0).timeout
		call_deferred("load_garage_scene")

func load_garage_scene():
	get_tree().change_scene_to_packed(garage_scene)
	
func on_health_changed(percentage: float):
	health_bar.value = percentage
