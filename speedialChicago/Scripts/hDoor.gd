extends RigidBody2D

var broken = false
var soundSafe = true

func _on_right_body_entered(body: Node2D) -> void:
	if body.get("dead") != null:
		if !broken:
			playRandom()
			broken = true
		else:
			playRandom(true)
		apply_impulse(Vector2(0, 1) * 600)
		apply_central_impulse(Vector2(0, 1) * 600)

func playRandom(_nonRand: bool = false):
	if _nonRand:
		if soundSafe:
			soundSafe = false
			Manager.playSound("doorOpen3", global_position)
			wait()
		return

	var rand = randi_range(1, 2)
	match rand:
		1:
			Manager.playSound("doorOpen1", global_position)
		2:
			Manager.playSound("doorOpen2", global_position)

func wait():
	await get_tree().create_timer(.5).timeout
	soundSafe = true

func _on_left_body_entered(body: Node2D) -> void:
	if body.get("dead") != null:
		if !broken:
			playRandom()
			broken = true
		else:
			playRandom(true)
		apply_impulse(Vector2(0, -1) * 600)
		apply_central_impulse(Vector2(0, -1) * 600)
