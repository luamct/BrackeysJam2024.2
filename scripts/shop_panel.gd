class_name ShopPanel
extends PanelContainer

signal module_selected(module: ModuleResource)

@export var available_modules: Array[ModuleResource]

@onready var grid_container: GridContainer = $GridContainer

const MODULE_BUTTON_SCENE = preload("res://scenes/module_button.tscn")
const TILESET = preload("res://resources/Tileset.tres")

func _ready() -> void:
	for module in available_modules:
		var module_button: TextureButton = MODULE_BUTTON_SCENE.instantiate()
		var atlas_texture = module_button.texture_normal as AtlasTexture
		var atlas: TileSetAtlasSource = TILESET.get_source(module.source_id)
		atlas_texture.region = atlas.get_tile_texture_region(module.atlas_coords)
		
		module_button.pressed.connect(func(): module_button_pressed(module))
		grid_container.add_child(module_button)

func module_button_pressed(module: ModuleResource):
	module_selected.emit(module)
	
