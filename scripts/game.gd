class_name Game
extends Node2D

const source_id = 1
const tile_coords = Vector2i(3, 3)
@onready var tile_map: TileMapLayer = $ModulesTileMapLayer

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	
	if Input.is_action_just_pressed("left_click"):
		var mouse_position = get_global_mouse_position()
		var tile = tile_map.local_to_map(mouse_position)
		print("Clicked tile: ", tile)
		tile_map.set_cell(tile, source_id, tile_coords)

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
