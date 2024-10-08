class_name MachineGun
extends Node2D

const SCENE: PackedScene = preload("res://scenes/modules/machine_gun.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")

@onready var timer: Timer = $CooldownTimer

var grid_coords: Vector2i
var level: Level

var bullet_impulse: int = 500
var max_range: int = 150
#var fire_rate: float # Shots per second
var damage: int # Per shot

static func create(module: ModuleResource, _position: Vector2, grid_coords: Vector2i) -> MachineGun:
	var instance: MachineGun = SCENE.instantiate()
	#instance.fire_rate = module.fire_rate
	instance.damage = module.damage
	instance.grid_coords = grid_coords
	instance.position = _position
	return instance

func _ready():
	timer.wait_time = Globals.fire_rates[grid_coords]
	timer.timeout.connect(on_cooldown_timeout)
	
	level = get_tree().get_first_node_in_group("level")
	
func on_cooldown_timeout():
	var target_enemy: Enemy = null
	var target_distance: float = 10e10
	
	#print(level.enemies.size())
	for enemy: Enemy in level.enemies:
		var distance: float = enemy.global_position.distance_to(global_position)
		if distance < target_distance && distance <= max_range:
			target_enemy = enemy
			target_distance = distance

	if target_enemy == null:
		return

	Audio.play_gun()
	
	var shoot_direction: Vector2 = (target_enemy.global_position - global_position).normalized()
	var bullet: RigidBody2D = BULLET_SCENE.instantiate()
	bullet.global_position = global_position
	bullet.damage = damage
	#bullet.global_rotation = shoot_direction.angle() + PI*0.5
	bullet.apply_impulse(shoot_direction * bullet_impulse)
	get_tree().get_root().add_child(bullet)
