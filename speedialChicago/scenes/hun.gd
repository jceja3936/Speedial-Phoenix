extends Sprite2D

var ammo = 21;
var mags = 0;
var currentSprite: Texture
var pistol: PackedScene = load("res://scenes/pistol.tscn")


func update_values(value: int):
	currentSprite = null
	match value:
		1:
			currentSprite = load("res://assets/basicSquare.svg")

	texture = currentSprite

func dropWeapon(gun: int):
	var pistolInstance = pistol.instantiate()
	pistolInstance.setAmmo(ammo)
	pistolInstance.set_collision_layer_value(2, true)
	pistolInstance.set_collision_mask_value(2, true)
	pistolInstance.set_collision_layer_value(1, false)
	pistolInstance.set_collision_mask_value(1, false)
	pistolInstance.position = global_position
	get_tree().root.add_child(pistolInstance)
