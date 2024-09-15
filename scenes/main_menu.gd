extends Control

func _ready():
	Audio.play_menu()
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _input(_event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
