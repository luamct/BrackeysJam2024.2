extends Control

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/garage.tscn")

func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
