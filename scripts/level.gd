class_name Level
extends Node2D

@onready var vehicle: Vehicle = $Vehicle
@onready var health_bar: ProgressBar = %HealthBar

func _ready():
	vehicle.health_changed.connect(on_health_changed)
	health_bar.value = 1.0

func on_health_changed(percentage: float):
	health_bar.value = percentage
