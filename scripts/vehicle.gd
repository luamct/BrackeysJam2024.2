class_name Vehicle
extends CharacterBody2D

const SOURCE_ID = 0
const MACHINE_GUN_SCENE = preload("res://scenes/modules/machine_gun.tscn")

# Steering and acceleration
var wheel_base = 50  # Distance from front to rear wheel
@export var steering_angle: int  # Amount that front wheel turns, in degrees
@export var engine_power: int  # Forward acceleration force.

# Deccelaration
@export var friction: int # Resistance from the ground
@export var drag: float # Resistance from the air
@export var braking: int
@export var max_speed_reverse: int

# Drifting
@export var slip_speed: int  # Speed where traction is reduced
@export var traction_fast: float # High-speed traction
@export var traction_slow: float  # Low-speed traction

var acceleration = Vector2.ZERO
var steer_direction

@onready var modules_tile_map: TileMapLayer = $ModulesTileMapLayer
@onready var modules: Node2D = $Modules

func _ready():
	for coords in VehicleGrid.grid:
		var module: ModuleResource = VehicleGrid.grid[coords]
		modules_tile_map.set_cell(coords, SOURCE_ID, module.topdown_atlas_coords)
		
		match module.name:
			"MachineGun":
				var instance: MachineGun = MACHINE_GUN_SCENE.instantiate()
				instance.grid_position = coords
				instance.damage = module.damage
				instance.fire_rate = module.fire_rate
				modules.add_child(instance)

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func get_input():
	var turn = Input.get_axis("steer_left", "steer_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	# choose which traction value to use - at lower speeds, slip should be low
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
