extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 800
@export var jump = -800
@export var health = 200
@export var shootSFX: AudioStreamPlayer2D
@export var bullet: PackedScene = load("res://scenes/bullet.tscn")

var dead = false
var deathTexture: Texture = load("res://assets/icon.svg")
var canFire = false
var playa = true
var rng = RandomNumberGenerator.new()
var fireRate = .2
var gunPickedUp = false


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and canFire:
		fire()


	if dead:
		return
	

func hit() -> void:
	health -= 100
	if health <= 0:
		die()
	
func die() -> void:
	return
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
	bullet.pos = $gun.global_position
	bullet.rota = global_rotation
	add_child(bullet)
	await get_tree().create_timer(1).timeout
	if bullet:
		bullet.queue_free()


func _fireRateControll() -> void:
	if dead:
		return
	canFire = true
	await get_tree().create_timer(fireRate).timeout
	_fireRateControll()

func _on_pistol_picked_up(float: Variant) -> void:
	fireRate = float
	gunPickedUp = true
	_fireRateControll()
	print(fireRate)
