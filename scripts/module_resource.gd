class_name ModuleResource
extends Resource

@export var name: String
@export var atlas_coords: Vector2i
@export var topdown_atlas_coords: Vector2i
@export var cost: int
@export var damage: int
@export var fire_rate: float

func description() -> String:
	return "Description for module " + name
