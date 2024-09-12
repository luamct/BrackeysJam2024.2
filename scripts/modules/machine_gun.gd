class_name MachineGun
extends Node2D

const SCENE: PackedScene = preload("res://scenes/modules/machine_gun.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")

@onready var timer: Timer = $CooldownTimer

var grid_position: Vector2
var enemy_manager: EnemyManager

var bullet_impulse: int = 500
var max_range: int = 300
var fire_rate: float # Shots per second
var damage: int # Per shot

static func create(module: ModuleResource, _position: Vector2) -> MachineGun:
	var instance: MachineGun = SCENE.instantiate()
	instance.fire_rate = module.fire_rate
	instance.damage = module.damage
	instance.position = _position
	return instance

func _ready():
	timer.wait_time = fire_rate
	timer.timeout.connect(on_cooldown_timeout)
	
	enemy_manager = get_tree().get_first_node_in_group("enemy_manager")
	
func on_cooldown_timeout():
	var target_enemy: Enemy = null
	var target_distance: float = 10e10
	
	for enemy: Enemy in enemy_manager.enemies:
		var distance: float = enemy.global_position.distance_to(global_position)
		if distance < target_distance && distance <= max_range:
			target_enemy = enemy
			target_distance = distance
	
	if target_enemy == null:
		return

	var shoot_direction: Vector2 = (target_enemy.global_position - global_position).normalized()
	var bullet: RigidBody2D = BULLET_SCENE.instantiate()
	bullet.global_position = global_position
	bullet.damage = damage
	#bullet.global_rotation = shoot_direction.angle() + PI*0.5
	bullet.apply_impulse(shoot_direction * bullet_impulse)
	get_tree().get_root().add_child(bullet)
