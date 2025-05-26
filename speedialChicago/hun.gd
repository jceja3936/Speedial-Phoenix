extends Sprite2D

var ammo = 21;
var mags = 0;
var currentSprite: Texture
var pistol: PackedScene = load("res://scenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/rifle.tscn")


func update_values(value: int):
	currentSprite = null
	match value:
		1:
			currentSprite = load("res://assets/basicSquare.svg")
			rotation = 0
			scale.x = .9
			scale.y = .25
		2:
			currentSprite = load("res://assets/Guitar-b.svg")
			scale.x = 0.612
			scale.y = 0.622
			rotation_degrees = 72.9


	texture = currentSprite

func dropWeapon(gun: int):
	match gun:
		1:
			var pistolInstance = pistol.instantiate()
			pistolInstance.setAmmo(ammo)
			pistolInstance.set_collision_layer_value(2, true)
			pistolInstance.set_collision_mask_value(2, true)
			pistolInstance.set_collision_layer_value(1, false)
			pistolInstance.set_collision_mask_value(1, false)
			pistolInstance.position = global_position
			get_tree().root.add_child(pistolInstance)
		2:
			var rifleInstance = rifle.instantiate()
			rifleInstance.setAmmo(ammo)
			rifleInstance.set_collision_layer_value(2, true)
			rifleInstance.set_collision_mask_value(2, true)
			rifleInstance.set_collision_layer_value(1, false)
			rifleInstance.set_collision_mask_value(1, false)
			rifleInstance.position = global_position
			get_tree().root.add_child(rifleInstance)
