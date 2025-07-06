extends Node2D

var closeEnough = false
var lastEntered = null
var currentAmmo = 4
@export var mySound: AudioStreamPlayer2D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pick up") and closeEnough:
		if lastEntered.has_method("weaponGrabbed") and !lastEntered.get("gunPickedUp"):
			lastEntered.call("weaponGrabbed", 4, currentAmmo)
			queue_free()

func setAmmo(amount: int):
	currentAmmo = amount


func _on_area_2d_body_exited(_body: Node2D) -> void:
	closeEnough = false
	lastEntered = null


func _on_area_2d_body_entered(body: Node2D) -> void:
	closeEnough = true
	lastEntered = body
