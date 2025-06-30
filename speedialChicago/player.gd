extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 750
@export var jump = -800
@export var health = 200
@export var cam: Camera2D

var bullet: PackedScene = preload("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/icon.svg")

var dead = false
var canFire = false
var gunPickedUp = false

var rng = RandomNumberGenerator.new()
var playa = true
var cameFollow = true
var amAm
var resp


func _ready() -> void:
	var amamNode = ""
	var respNode = ""

	match Manager.current_scene:
		"1_1":
			respNode = "/root/Lvl1/Camera2D/Respawn"
			amamNode = "/root/Lvl1/Camera2D/AmAm"
		"1_2":
			respNode = "/root/1_2/Camera2D/Respawn"
			amamNode = "/root/1_2/Camera2D/AmAm"
		"1_3":
			respNode = "/root/lvl1END/Camera2D/Respawn"
			amamNode = "/root/lvl1END/Camera2D/AmAm"

	amAm = get_node(amamNode)
	resp = get_node(respNode)

	if Manager.gunType != 0:
		weaponGrabbed(Manager.gunType, Manager.ammoCount)

var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0:
		die()
		resp.show()
	
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
		cam.setCam(1)
	elif Input.is_action_just_pressed("esc") and !cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		cam.setCam(0)

	if Input.is_action_pressed("extendCam") and cameFollow:
		cam.setCam(2)

	if Input.is_action_just_released("extendCam"):
		cam.setCam(0)

	if dead:
		return


	look_at(get_global_mouse_position())
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	if dir:
		position += dir * speed * delta
	else:
		velocity = Vector2(0, 0)

	move_and_slide()
	
func makeHunSave():
	$hun.saveWeapon()

#value is fire rate, gun is guntype, bulldam is bullet damage
func weaponGrabbed(which: int, currentAmmo: int) -> void:
	$hun.update_values(which, currentAmmo)
	gunPickedUp = true
	amAm.show()
