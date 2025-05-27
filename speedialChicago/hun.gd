extends Sprite2D

var ammo = 21;
var mags = 0;
var currentSprite: Texture
var pistol: PackedScene = load("res://scenes/pistol.tscn")
var rifle: PackedScene = load("res://scenes/rifle.tscn")
var shotgun: PackedScene = load("res://scenes/shotgun.tscn")


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
		3:
			currentSprite = load("res://assets/Frog 2-c.svg")
			rotation_degrees = 17.0
			scale.x = 0.612
			scale.y = 0.289


	texture = currentSprite

func instantiate(type: PackedScene):
	var instance = type.instantiate()
	instance.setAmmo(ammo)
	instance.set_collision_layer_value(2, true)
	instance.set_collision_mask_value(2, true)
	instance.set_collision_layer_value(1, false)
	instance.set_collision_mask_value(1, false)
	instance.position = global_position
	get_tree().root.add_child(instance)

func dropWeapon(gun: int):
	match gun:
		1:
			instantiate(pistol)
		2:
			instantiate(rifle)
		3:
			instantiate(shotgun)
