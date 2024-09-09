class_name ShopPanel
extends PanelContainer

signal module_selected(module: ModuleResource)
@export var available_modules: Array[ModuleResource]

@onready var grid_container: GridContainer = $GridContainer

const MODULE_BUTTON = preload("res://scenes/module_button.tscn")

func _ready() -> void:
	for module in available_modules:
		var module_instance = MODULE_BUTTON.instantiate()
		grid_container.add_child(module_instance)
		
	
	var buttons: Array[Node] = $GridContainer.get_children()
	var i = 0
	for button: BaseButton in buttons:
		button.pressed.connect(func(): module_button_pressed(i))
		i += 1

func module_button_pressed(module_index: int):
	module_selected.emit(available_modules[module_index])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
