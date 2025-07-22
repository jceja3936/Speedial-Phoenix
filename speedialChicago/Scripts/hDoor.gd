extends RigidBody2D

func _on_right_body_entered(body: Node2D) -> void:
	if body.get("dead") != null:
		apply_impulse(Vector2(0, 1) * 600)
		apply_central_impulse(Vector2(0, 1) * 600)

func _on_left_body_entered(body: Node2D) -> void:
	if body.get("dead") != null:
		apply_impulse(Vector2(0, -1) * 600)
		apply_central_impulse(Vector2(0, -1) * 600)
