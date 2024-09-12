class_name Enemy
extends Node2D

signal death(enemy: Enemy)

@export var health: int = 10

@onready var area: Area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	area.body_entered.connect(on_body_entered)
	
func on_body_entered(body: Node):
	print("Enemy was hit: ", body.name)
	if body is Bullet:
		health -= body.damage
		body.queue_free()
		
		if health <= 0:
			die()
		
func die():
	animated_sprite_2d.play("dead")
	death.emit(self)
	queue_free()
