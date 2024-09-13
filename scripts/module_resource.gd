class_name ModuleResource
extends Resource

@export var name: String
@export var atlas_coords: Vector2i
@export var topdown_atlas_coords: Vector2i
@export var cost: int
@export var damage: int
@export var fire_rate: float

func description() -> String:
	var desc = ""
	match name:
		"MachineGun":
			desc += "Turret\n"
			desc += "Damage: " + str(damage) + "\n"
			desc += "Shoots every " + str(fire_rate) + " s\n"
			desc += "Cost: " + str(cost) + "\n"

		_:
			desc += "TODO"

	return desc
