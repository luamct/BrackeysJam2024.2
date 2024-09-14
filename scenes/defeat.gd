extends Control

@onready var garage_scene: PackedScene = load("res://scenes/garage.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_packed(garage_scene)
	
func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
