extends CharacterBody2D

var closeEnough = false
var lastEntered = null
var currentAmmo = 60


func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("Pick up") and closeEnough:
        if lastEntered.has_method("weaponGrabbed") and lastEntered.get("gunPickedUp") != true:
            lastEntered.call("weaponGrabbed", .1, 2, currentAmmo, 80)
            queue_free()

func setAmmo(amount: int):
    currentAmmo = amount


func _on_area_2d_body_exited(_body: Node2D) -> void:
    closeEnough = false
    lastEntered = null

func _on_area_2d_body_entered(_body: Node2D) -> void:
    closeEnough = true
    lastEntered = _body
