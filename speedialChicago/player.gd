extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 800
@export var jump = -800
@export var health = 200
@export var shootSFX: AudioStreamPlayer2D
@export var bullet: PackedScene = load("res://scenes/bullet.tscn")
@export var camera: Camera2D

var dead = false
var deathTexture: Texture = load("res://assets/icon.svg")
var canFire = false

var rng = RandomNumberGenerator.new()
var fireRate = .2
var playa = true
var gunPickedUp = false
var ammo = 0
var gunType = 0

func _ready():
	_fireRateControll()

func _physics_process(delta: float) -> void:
	if dead:
		return

	if Input.is_action_just_pressed("Drop") and gunPickedUp:
		$hun.set("ammo", ammo)
		$hun.dropWeapon(gunType)
		camera.get_child(0).hide()
		$hun.update_values(0)
		ammo = 0
		gunPickedUp = false

	if Input.is_action_pressed("shoot") and canFire and ammo > 0:
		fire()
		ammo -= 1
		camera.get_child(0).text = "Ammo: " + str(ammo)

	
func hit() -> void:
	health -= 100
	if health <= 0:
		die()
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionPolygon2D.queue_free()
	dead = true;

func _process(delta: float) -> void:
	if dead:
		return
	
	look_at(get_global_mouse_position())
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	if dir:
		position += dir * speed * delta
	else:
		velocity = Vector2(0, 0)
	move_and_slide()
	
func fire() -> void:
	shootSFX.play()
	canFire = false
	var bullet = bullet.instantiate()
	bullet.dir = rotation + rng.randf_range(-.08, .08)
	bullet.pos = $hun.global_position
	bullet.rota = global_rotation
	add_child(bullet)
	await get_tree().create_timer(1).timeout
	if bullet:
		bullet.queue_free()


func _fireRateControll() -> void:
	if dead:
		return
	if !gunPickedUp:
		canFire = false
	else:
		canFire = true
	await get_tree().create_timer(fireRate).timeout
	_fireRateControll()


func weaponGrabbed(value: float, gun: int, currentAmmo: int) -> void:
	fireRate = value
	gunPickedUp = true
	camera.get_child(0).show()
	ammo = currentAmmo
	camera.get_child(0).text = "Ammo: " + str(ammo)
	$hun.update_values(gun)
	gunType = gun
