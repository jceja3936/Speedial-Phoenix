extends Node2D

var closeEnough = false
var lastEntered = null
var currentAmmo = 21

func _on_area_2d_body_entered(body: Node2D) -> void:
	closeEnough = true
	lastEntered = body
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	closeEnough = false
	lastEntered = null
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Pick up") and closeEnough:
		if lastEntered.has_method("weaponGrabbed"):
			lastEntered.call("weaponGrabbed", .2, 1, currentAmmo)
			queue_free()

func setAmmo(amount: int):
	currentAmmo = amount