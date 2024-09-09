extends PanelContainer

#@onready var button_container: TextureButton = 

func _ready() -> void:
	var buttons: Array[Node] = $GridContainer.get_children()
	for button: BaseButton in buttons:
		button.pressed.connect(func(): module_button_pressed(button.name))

func module_button_pressed(name: String):
	print("pressed ", name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
