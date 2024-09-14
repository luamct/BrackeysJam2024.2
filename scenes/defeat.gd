extends Control

@onready var garage_scene: PackedScene = load("res://scenes/garage.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_retry_pressed() -> void:
	Globals.reset()
	get_tree().change_scene_to_packed(garage_scene)
	
func _input(_event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
