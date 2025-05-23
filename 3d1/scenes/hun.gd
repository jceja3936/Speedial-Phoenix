extends Sprite2D

var ammo = 21;
var mags = 0;
var currentSprite: Texture

func update_values(value: int):
	print(value)
	match value:
		1:
			currentSprite = load("res://assets/basicSquare.svg")
	update_Self()

func update_Self():
	if (currentSprite != null):
		texture = currentSprite

func getAmmo():
	return ammo
func getMags():
	return mags