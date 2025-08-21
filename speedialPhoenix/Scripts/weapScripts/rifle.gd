extends CharacterBody2D

var closeEnough = false
var lastEntered = null
var currentAmmo = 30
var dropped = false
var x = 0.0
var curve: Curve = load("res://assets/prac.tres")

var randDeg
var randDir

var bulletImage: Texture = load("res://assets/img/ammoPack.png")

func _ready():
	if Manager.chosenChar == 1:
		$Sprite2D.texture = bulletImage
	if dropped:
		bugFix()
	else:
		$Area2D.monitoring = true

	randDeg = randi_range(20, 40)
	randDir = randf_range(-3.14, 3.14)

func bugFix():
	await get_tree().create_timer(.2).timeout
	$Area2D.monitoring = true

func _process(_delta: float) -> void:
	if dropped:
		x = lerp(x, 1.0, .08)
		rotation += deg_to_rad(curve.sample(x) * randDeg)
		velocity = curve.sample(x) * Vector2(800, 0).rotated(randDir)
		move_and_slide()
	if x >= 0.9:
		dropped = false
		set_collision_layer_value(1, false)

	if Input.is_action_just_pressed("Pick up") and closeEnough:
		if lastEntered.has_method("weaponGrabbed") and lastEntered.get("gunPickedUp") != true:
			lastEntered.call("weaponGrabbed", 2, currentAmmo)
			queue_free()

func setAmmo(amount: int):
	currentAmmo = amount


func _on_area_2d_body_exited(_body: Node2D) -> void:
	closeEnough = false
	lastEntered = null

func _on_area_2d_body_entered(_body: Node2D) -> void:
	closeEnough = true
	lastEntered = _body
	if Manager.chosenChar == 1 and lastEntered.has_method("weaponGrabbed"):
		lastEntered.call("weaponGrabbed", 1, currentAmmo)
		queue_free()
