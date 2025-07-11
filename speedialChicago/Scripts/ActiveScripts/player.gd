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

var camExt = false
var finish = false


func _ready() -> void:
	SignalBus.finishing.connect(finishing)
	SignalBus.updateResp.emit(false)
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos
	if Manager.gunType != 0:
		weaponGrabbed(Manager.gunType, Manager.ammoCount)

func finishing(value: Vector2, enemy: CharacterBody2D):
	finish = true
	position = value
	await get_tree().create_timer(.15).timeout
	Manager.playSound("punched", global_position)
	await get_tree().create_timer(.15).timeout
	Manager.playSound("punched", global_position)
	if enemy:
		enemy.call("hit", 290)

	finish = false


var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0:
		die()

func die() -> void:
	SignalBus.updateResp.emit(true)
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
	if dead or finish:
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
	SignalBus.updateAmmo.emit(currentAmmo)
	gunPickedUp = true
