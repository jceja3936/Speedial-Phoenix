extends Sprite2D

var tweener = 2.0

func _ready() -> void:
	SignalBus.updateScore.connect(makePretty)
	setColor()

func setColor():
	if Manager.chosenChar == 1:
		material.set_shader_parameter("myColor", Color8(0, 156, 0, 255))
	else:
		material.set_shader_parameter("myColor", Color8(255, 0, 0, 255))


func makePretty(_g: int):
	tweener = 2.0
	material.set_shader_parameter("myOpaq", tweener)
	finisher()


func finisher():
	await get_tree().create_timer(.05).timeout
	tweener -= .2
	material.set_shader_parameter("myOpaq", tweener)
	if tweener > 0:
		finisher()