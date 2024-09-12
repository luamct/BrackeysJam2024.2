class_name Bullet
extends RigidBody2D

var damage: int = 0

@onready var auto_destroy_timer: Timer = $AutoDestroyTimer

func _ready():
	auto_destroy_timer.timeout.connect(queue_free)
