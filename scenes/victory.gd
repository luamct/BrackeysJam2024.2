extends Control

@onready var garage_scene: PackedScene = load("res://scenes/garage.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_playagain_pressed() -> void:
	Globals.reset()
	get_tree().change_scene_to_packed(garage_scene)
	
func _input(_event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
