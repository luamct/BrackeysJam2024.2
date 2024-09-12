class_name EnemyManager
extends Node2D

var enemies: Array[Enemy]

func _ready():
	print("EM ready!")
	enemies.assign(get_children())
	print(enemies.size())
