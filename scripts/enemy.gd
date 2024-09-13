class_name Enemy
extends Node2D

signal death(enemy: Enemy)

const engagement_distance: int = 300

@export var health: int
@export var speed: int

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Vehicle

func _ready():
	area.body_entered.connect(on_body_entered)
	player = get_tree().get_first_node_in_group("player")

func on_body_entered(body: Node):
	if body is Bullet:
		health -= body.damage
		body.queue_free()

		if health <= 0:
			die()

func die():
	sprite.play("dead")
	death.emit(self)
	area.set_deferred("monitorable", false)
	area.set_deferred("monitoring", false)
	#queue_free()

func _physics_process(delta: float) -> void:
	var distance = position.distance_to(player.position)
	print("Distance to player:", distance)
	if distance < engagement_distance:
		if sprite.animation != "walking":
			sprite.play("walking")
		
		position = position.move_toward(player.position, speed * delta)
		rotation = position.angle_to_point(player.position)
