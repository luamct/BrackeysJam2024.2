class_name Game
extends Node2D


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	if Input.is_action_just_pressed("left_click"):
		print("click")
