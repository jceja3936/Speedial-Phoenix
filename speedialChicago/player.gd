extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 800
@export var jump = -800
@export var health = 200
@export var shootSFX: AudioStreamPlayer2D
@export var camera: Camera2D

var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var dead = false
var canFire = false

var rng = RandomNumberGenerator.new()
var fireRate = .2
var playa = true
var gunPickedUp = false
var ammo = 0
var gunType = 0
var dammage = 100

func _ready():
	_fireRateControll()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Respawn") and dead:
		get_tree().change_scene_to_file("res://scenes/level.tscn")

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

	
func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	camera.get_child(1).show()
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
	var bull = bullet.instantiate()
	bull.dir = rotation + rng.randf_range(-.08, .08)
	bull.pos = $hun.global_position
	bull.rota = global_rotation
	bull.damage = dammage
	add_child(bull)
	await get_tree().create_timer(1).timeout
	if bull:
		bull.queue_free()


func _fireRateControll() -> void:
	if dead:
		return
	if !gunPickedUp:
		canFire = false
	else:
		canFire = true
	await get_tree().create_timer(fireRate).timeout
	_fireRateControll()

#value is fire rate, gun is guntype, bulldam is bullet damage

func weaponGrabbed(value: float, gun: int, currentAmmo: int, bullDam: int) -> void:
	fireRate = value
	gunPickedUp = true
	camera.get_child(0).show()
	dammage = bullDam
	ammo = currentAmmo
	camera.get_child(0).text = "Ammo: " + str(ammo)
	$hun.update_values(gun)
	gunType = gun
