extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 800
@export var jump = -800
@export var health = 200
@export var shootSFX :  AudioStreamPlayer2D
@export var bullet : PackedScene = load("res://scenes/bullet.tscn")
@export var gun : Node2D
var dead = false
var deathTexture : Texture = load("res://assets/icon.svg")
var canFire : bool
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	canFire = true
	
func _physics_process(delta: float) -> void:
	
	if dead:
		return
	
	if Input.is_action_pressed("shoot"):
		if canFire:
			shootSFX.play()
			fire()

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
	var dir = Input.get_vector("Left","Right", "Up", "Down")
	if dir:
		position += dir * speed * delta
	else:
		velocity = Vector2(0,0)
	move_and_slide()
	
func fire() -> void:
	canFire = false
	var bullet = bullet.instantiate()
	bullet.dir = rotation + rng.randf_range(-.08, .08)
	bullet.pos = gun.global_position
	bullet.rota = global_rotation
	add_child(bullet)
	await get_tree().create_timer(1).timeout
	if bullet:
		bullet.queue_free()

func _on_timer_timeout() -> void:
	if dead:
		return
	canFire = true
