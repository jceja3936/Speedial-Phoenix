extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 200
@export var jump = -800
@export var jumpSFX : AudioStreamPlayer2D
@export var bullet : PackedScene = load("res://scenes/bullet.tscn")
@export var gun : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("shoot"):
		fire()
		
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = jump / 4
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		jumpSFX.play()
	var dir = Input.get_axis("Left","Right")
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
func fire() -> void:
	var bullet = bullet.instantiate()
	bullet.dir = get_angle_to(get_global_mouse_position())
	bullet.pos = gun.global_position
	bullet.rota = global_rotation
	$bullets.add_child(bullet)
	
