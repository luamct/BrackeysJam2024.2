class_name MachineGun
extends Node2D

const SCENE: PackedScene = preload("res://scenes/modules/machine_gun.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")

@onready var timer: Timer = $CooldownTimer

var grid_position: Vector2i
var enemy_manager: EnemyManager

var fire_rate: int = 2  # Shots per second
var damage: int = 5 # Per shot
var range: int = 10

static func new(_grid_position: Vector2i, _enemy_manager: EnemyManager) -> MachineGun:
	var instance: MachineGun = SCENE.instantiate()
	instance.grid_position = _grid_position
	instance.enemy_manager = _enemy_manager
	return instance

func _ready():
	timer.wait_time = 1.0/fire_rate
	timer.timeout.connect(on_cooldown_timeout)
	
	# TODO: Remove hard coded values
	grid_position = Vector2i.ZERO
	enemy_manager = get_tree().get_first_node_in_group("enemy_manager")
	
func on_cooldown_timeout():
	print("Shoot!")

	var target_enemy: Enemy = null
	var target_distance: float = 10e10
	
	for enemy: Enemy in enemy_manager.enemies:
		var distance: float = enemy.global_position.distance_to(global_position)
		if distance < target_distance:
			target_enemy = enemy
			target_distance = distance
	
	var shoot_direction: Vector2 = (target_enemy.global_position - global_position).normalized()
	var bullet: RigidBody2D = BULLET_SCENE.instantiate()
	add_child(bullet)
	bullet.global_rotation = shoot_direction.angle() + PI*0.5
	bullet.apply_impulse(shoot_direction * 2000)
	
	
#func _process(delta):
	
