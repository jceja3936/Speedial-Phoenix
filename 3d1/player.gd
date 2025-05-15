extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 800
@export var jump = -800
@export var shootSFX :  AudioStreamPlayer2D
@export var bullet : PackedScene = load("res://scenes/bullet.tscn")
@export var gun : Node2D
var canFire : bool


func _ready() -> void:
	canFire = true
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if canFire:
			shootSFX.play()
			fire()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	var dir = Input.get_vector("Left","Right", "Up", "Down")
	if dir:
		position += dir * speed * delta
	else:
		velocity = Vector2(0,0)
	move_and_slide()
	
func fire() -> void:
	canFire = false
	var bullet = bullet.instantiate()
	bullet.dir = get_angle_to(get_global_mouse_position())
	bullet.pos = gun.global_position
	bullet.rota = global_rotation
	add_child(bullet)
	await get_tree().create_timer(1).timeout
	if bullet:
		bullet.queue_free()
	

func _on_timer_timeout() -> void:
	canFire = true
