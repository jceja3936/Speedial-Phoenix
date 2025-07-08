extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 750
@export var jump = -800
@export var health = 200
@export var cam: Camera2D

var bullet: PackedScene = preload("res://scenes/bullet.tscn")
var deathTexture: Texture = load("res://assets/img/icon.svg")

var dead = false
var canFire = false
var gunPickedUp = false

var rng = RandomNumberGenerator.new()
var playa = true
var cameFollow = true
var amAm
var resp
var camExt = false


func _ready() -> void:
	var amamNode = ""
	var respNode = ""

	match Manager.current_scene:
		"1_1":
			respNode = "/root/Lvl1/Camera2D/Respawn"
			amamNode = "/root/Lvl1/Camera2D/AmAm"

	amAm = get_node(amamNode)
	resp = get_node(respNode)

	if Manager.gunType != 0:
		weaponGrabbed(Manager.gunType, Manager.ammoCount)
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos

var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0:
		die()
		resp.show()
	
func die() -> void:
	dead = true
	$Sprite2D.texture = deathTexture
	$Sprite2D.scale.x = 1
	$Sprite2D.scale.y = 1
	$CollisionShape2D.queue_free()
	$hun.set_script(null)

func _input(event):
	if event.is_action_pressed("esc") and cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cameFollow = false
		cam.setCam(1)
	elif event.is_action_pressed("esc") and !cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		cam.setCam(0)

	if event.is_action_pressed("extendCam") and cameFollow and !camExt:
		cam.setCam(2)
		camExt = true

	if event.is_action_released("extendCam"):
		cam.setCam(0)
		camExt = false

	if event.is_action_pressed("Respawn") and dead:
		dead = false
		Manager.startNextScene()


func _physics_process(delta: float) -> void:
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
