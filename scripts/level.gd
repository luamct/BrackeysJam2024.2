class_name Level
extends Node2D

const SOURCE_ID = 0
const SAND_TILE_COORD = Vector2i(0, 0)
const STORM_TILE_COORD = Vector2i(1, 0)
const MOUNTAIN_TILE_COORD = Vector2i(2, 0)
const START_TILE_COORD = Vector2i(3, 0)
const GOAL_TILE_COORD = Vector2i(4, 0)
const NOISE_RANGE = 0.7
const LING = preload("res://scenes/enemies/ling.tscn")
const BRUTE = preload("res://scenes/enemies/brute.tscn")
const STORM_AREA = preload("res://scenes/storm_area.tscn")
const STORM_EDGE = preload("res://scenes/storm_edge.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
@onready var storm_damage_timer: Timer = $StormDamageTimer
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
				var tile_coord: Vector2i = types_to_tiles[level_area.type]
				var r = randf()
				if r < 0.4: tile_coord.y = 0
				elif r < 0.7: tile_coord.y = 1
				elif r < 1.0: tile_coord.y = 2

				tile_map.set_cell(Vector2i(starting_x + x, y), SOURCE_ID, tile_coord)

		starting_x += level_area.length

	goal_area.body_entered.connect(on_body_entered_goal_area)
	storm_damage_timer.timeout.connect(on_storm_damage_timeout)
	
	place_enemies()

func place_enemies():
	var height = level_config.height
	var length = level_config.areas.reduce(func(total_length, a): return a.length + total_length, 0)
	enemy_noise.height = height
	enemy_noise.width = length
	var enemy_threshold = lerpf(-NOISE_RANGE, NOISE_RANGE, enemy_noise.color_ramp.offsets[1])
	#print("threshold ", enemy_threshold)
	#print("Offsets: ", enemy_noise.color_ramp.offsets)
	#print(length, " x ", height)

	# Noise values, just for statistics on the range
	var values = []

	var half_height = level_config.height/2
	var starting_x = 0
	for area in level_config.areas:
		if area.type == LevelAreaResource.AreaType.STORM:
			add_storm_areas(starting_x, area.length)
			
			for area_x in area.length:
				for y in range(-half_height, half_height):
					var x = starting_x + area_x
					var value = enemy_noise.noise.get_noise_2d(x, y)
					values.append(value)

					if value < enemy_threshold:
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
	#print("Noise range: (%f, %f)" % [values.min(), values.max()])

func add_storm_areas(x, length):
	var enter_area = STORM_AREA.instantiate()
	enter_area.position.x = x * tile_size
	enter_area.body_entered.connect(on_entering_storm)
	add_child(enter_area)
	
	var leave_area = STORM_AREA.instantiate()
	leave_area.position.x = (x + length) * tile_size
	leave_area.body_entered.connect(on_leaving_storm)
	add_child(leave_area)
	
	var storm_start = STORM_EDGE.instantiate()
	storm_start.position.x = x * tile_size
	add_child(storm_start)
	
	var storm_end = STORM_EDGE.instantiate()
	storm_end.rotation_degrees = 180
	storm_end.position.x = (x + length) * tile_size
	add_child(storm_end)
	
func on_entering_storm(_body):
	storm_damage_timer.start()
	print("storm")
	animation_player.play("storm")
	
func on_leaving_storm(_body):
	storm_damage_timer.stop()
	animation_player.stop()
	
func on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)

func on_body_entered_goal_area(body: Node2D):
	if body is Vehicle:
		vehicle.disable_controls()

		Globals.currency += level_config.reward
		currency_label.text = str(Globals.currency)
		Globals.current_level += 1

		await get_tree().create_timer(1.0).timeout
		if Globals.no_next_level():
			#Add Victory screen!
			get_tree().change_scene_to_packed(victory_scene)
			return
			#get_tree().quit()
			
		call_deferred("load_garage_scene")

func load_garage_scene():
	get_tree().change_scene_to_packed(garage_scene)
	
func on_health_changed(percentage: float):
	health_bar.value = percentage

func _process(_delta):
	%FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())

func on_storm_damage_timeout():
	vehicle.take_damage(level_config.storm_damage)
