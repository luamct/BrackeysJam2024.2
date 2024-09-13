class_name Garage
extends Node2D

const SOURCE_ID = 0
const TILESET = preload("res://resources/Tileset.tres")
const level1_scene: PackedScene = preload("res://scenes/level_1.tscn")

@onready var tile_map: TileMapLayer = $ModulesTileMapLayer
@onready var base_tile_map: TileMapLayer = $BaseTileMapLayer
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var shop_module_sprite: Sprite2D = $ShopModuleSprite
@onready var currency_label: Label = %CurrencyLabel
@onready var currency_skull: AnimatedSprite2D = $CanvasLayer/CurrencyContainer/CurrencySkull

#@onready var done_button: Button = $CanvasLayer/DoneButton

# Game mutable state
var selected_module: ModuleResource = null
var truck_size: Vector2i = Vector2i(4, 5)
#var player_currency: int = 12


func _ready() -> void:
	shop_panel.module_selected.connect(on_module_selected)
	currency_label.text = str(Globals.currency)
	currency_skull.play("idle")
	#done_button.pressed.connect(on_done_button_pressed)
	add_modules_to_tilemap()

func add_modules_to_tilemap():
	for coords in Globals.grid:
		var module: ModuleResource = Globals.grid[coords]
		tile_map.set_cell(coords, SOURCE_ID, module.atlas_coords)
		
func _on_done_button_pressed() -> void:
	get_tree().change_scene_to_packed(level1_scene)

func on_module_selected(module: ModuleResource):
	selected_module = module

func _input(event: InputEvent):
	if Input.is_action_just_pressed("left_click"):
		var mouse_position: Vector2 = tile_map.to_local(get_global_mouse_position())
		var tile_coords: Vector2i = tile_map.local_to_map(mouse_position)

		if selected_module != null:
			var base_cell: TileData = base_tile_map.get_cell_tile_data(tile_coords)
			if base_cell != null:
				if !Globals.grid.has(tile_coords):
					if Globals.currency >= selected_module.cost:
						tile_map.set_cell(tile_coords, SOURCE_ID, selected_module.atlas_coords)
						Globals.grid[tile_coords] = selected_module

						Globals.currency -= selected_module.cost
						currency_label.text = str(Globals.currency)
						currency_skull.play("buy")
					else: 
						print("Not enough money!")
				else:
					print("Slot already occupied!")

	if event is InputEventMouse:
		if selected_module != null:
			var mouse_position = tile_map.to_local(get_global_mouse_position())
			var tile = tile_map.local_to_map(mouse_position)

			var base_cell = base_tile_map.get_cell_tile_data(tile)
			if base_cell != null:
				var world_coords: Vector2 = base_tile_map.to_global(base_tile_map.map_to_local(tile))

				var atlas: TileSetAtlasSource = TILESET.get_source(SOURCE_ID)
				shop_module_sprite.texture.atlas.region = atlas.get_tile_texture_region(selected_module.atlas_coords)

				shop_module_sprite.visible = true
				shop_module_sprite.global_position = world_coords
			else:
				shop_module_sprite.visible = false

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

#func place_module(module: ModuleResource, position: Vector2i):
	#pass
	
#func get_module_sprite(module: ModuleResource) -> Texture2D:
	#var atlas: TileSetAtlasSource = TILESET.get_source(module.source_id)
	#var atlasImage = atlas.texture.get_image()
	#var tileImage = atlasImage.get_region(atlas.get_tile_texture_region(module.atlas_coords))
	#return ImageTexture.create_from_image(tileImage)
