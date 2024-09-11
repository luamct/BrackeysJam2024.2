class_name ShopPanel
extends Control

signal module_selected(module: ModuleResource)

@export var available_modules: Array[ModuleResource]

@onready var grid_container: GridContainer = $ModulesContainer/GridContainer
@onready var description_label: Label = %DescriptionLabel

const SOURCE_ID = 0
const MODULE_BUTTON_SCENE = preload("res://scenes/module_button.tscn")
const TILESET = preload("res://resources/Tileset.tres")

func _ready() -> void:
	for module in available_modules:
		var module_button: TextureButton = MODULE_BUTTON_SCENE.instantiate()
		var atlas_texture = module_button.texture_normal as AtlasTexture
		var atlas: TileSetAtlasSource = TILESET.get_source(SOURCE_ID)
		atlas_texture.region = atlas.get_tile_texture_region(module.atlas_coords)
		
		module_button.pressed.connect(func(): module_button_pressed(module))
		module_button.mouse_entered.connect(func(): on_mouse_hovering(module))
		grid_container.add_child(module_button)

func module_button_pressed(module: ModuleResource):
	module_selected.emit(module)
	
func on_mouse_hovering(module: ModuleResource):
	print(module.name)
	description_label.text = module.description()
