extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 1000
@export var jump = -800
@export var health = 200
@export var cam: Camera2D

var bullet: PackedScene = load("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var dead = false
var canFire = false
var gunPickedUp = false

var rng = RandomNumberGenerator.new()
var playa = true
var cameFollow = true

func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()
		get_node("/root/Lvl1/Camera2D/Respawn").show()
	
func die() -> void:
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	dead = true;
	$hun.set_script(null)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc") and cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cameFollow = false
		cam.setCam(false)
	elif Input.is_action_just_pressed("esc") and !cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		cam.setCam(true)

	if dead:
		return


	look_at(get_global_mouse_position())
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	if dir:
		position += dir * speed * delta
	else:
		velocity = Vector2(0, 0)

	move_and_slide()
	
	
#value is fire rate, gun is guntype, bulldam is bullet damage
func weaponGrabbed(which: int, currentAmmo: int) -> void:
	$hun.update_values(which, currentAmmo)
	gunPickedUp = true
	get_node("/root/Lvl1/Camera2D/AmAm").show()