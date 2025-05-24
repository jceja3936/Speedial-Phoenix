extends Sprite2D

var ammo = 21;
var mags = 0;
var currentSprite: Texture

func update_values(value: int):
	print(value)
	match value:
		1:
			currentSprite = load("res://assets/basicSquare.svg")
	if (currentSprite != null):
		texture = currentSprite
