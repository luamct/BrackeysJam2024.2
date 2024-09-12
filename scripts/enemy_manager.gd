class_name EnemyManager
extends Node2D

var enemies: Array[Enemy]

func _ready():
	for enemy in get_children():
		enemy.death.connect(on_enemy_died)
		enemies.append(enemy)

func on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)
