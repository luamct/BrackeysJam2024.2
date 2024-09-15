class_name Enemy
extends Node2D

signal death(enemy: Enemy)

const engagement_distance: int = 300

@export var health: int
@export var speed: int
@export var attack_speed: float  # Seconds between attacks
@export var damage: int

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var scan_cooldown: Timer = $ScanCooldown

var player: Vehicle
var meele_range: bool = false
var dead: bool = false
var alert: bool = false

func _ready():
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	player = get_tree().get_first_node_in_group("player")
	attack_cooldown.wait_time = attack_speed
	scan_cooldown.timeout.connect(on_scan_timeout)

func on_scan_timeout():
	var distance = position.distance_to(player.position)
	if distance < engagement_distance:
		alert = true
		scan_cooldown.stop()
		
	
func on_body_entered(body: Node):
	if body is Bullet:
		Audio.play_hit()
		
		health -= body.damage
		body.queue_free()

		if health <= 0:
			die()

	elif body is Vehicle:
		meele_range = true

func on_body_exited(body: Node):
	if body is Vehicle:
		meele_range = false

func die():
	dead = true
	sprite.play("dead")
	death.emit(self)
	area.set_deferred("monitorable", false)
	area.set_deferred("monitoring", false)

func _process(delta: float) -> void:
	if not alert or dead: 
		return

	if meele_range :
		if attack_cooldown.is_stopped():
			sprite.play("attack")  # Replace with attack animation
			attack_cooldown.start()
			player.take_damage(damage)

		return

	var distance = position.distance_to(player.position)
	if distance < engagement_distance:
		if sprite.animation != "walking":
			sprite.play("walking")
		
		position = position.move_toward(player.position, speed * delta)
		rotation = position.angle_to_point(player.position)
	
	else:
		sprite.play("idle")
	
