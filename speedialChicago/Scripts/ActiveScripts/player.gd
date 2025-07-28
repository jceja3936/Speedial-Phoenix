extends CharacterBody2D

const GRAVITY = 1000
@export var speed = 750
@export var jump = -800
@export var health = 200
@export var cam: Camera2D

var bullet: PackedScene = preload("res://scenes/bullet.tscn")

var dead = false
var canFire = false
var gunPickedUp = false

var rng = RandomNumberGenerator.new()
var playa = true
var cameFollow = true

var camExt = false
var finish = false
var gamePaused = false

var moved = false
var loop = false


func _ready() -> void:
	SignalBus.finishing.connect(finishing)
	SignalBus.paused.connect(paused)
	SignalBus.unPaused.connect(unPaused)
	SignalBus.levelBeat.connect(playAmbience)
	SignalBus.playCutscene.connect(cutScenePlaying)
	SignalBus.updateResp.emit(false)
	$shader.material.set_shader_parameter("myOpaq", 0.0)
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos
	if Manager.gunType != 0:
		weaponGrabbed(Manager.gunType, Manager.ammoCount)

func _notification(_what):
	return
	#This is a fix I don't yet know if I'm gonna implement
	#if what == NOTIFICATION_WM_MOUSE_EXIT:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#	cameFollow = false
	#	cam.setCam(1)
	#	$hun.stop()
	#	SignalBus.emit_signal("paused")

func cutScenePlaying():
	finish = true

func playAmbience():
	if !loop:
		loop = true
		$sound.play()
		await get_tree().create_timer(12.0).timeout
		loop = false


func paused():
	gamePaused = true
	Manager.gamePaused = true
func unPaused():
	gamePaused = false
	Manager.gamePaused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	cameFollow = true
	cam.setCam(0)
	$hun.unStop()


func finishing(value: Vector2, enemy: CharacterBody2D):
	if enemy and enemy.get("imHit") == true and !finish:
		finish = true
		position = value
		await get_tree().create_timer(.15).timeout
		Manager.playSound("punched", global_position, -5.0)
		await get_tree().create_timer(.15).timeout
		Manager.playSound("punched", global_position, -5.0)
		if enemy and enemy.get("imHit") == true:
			enemy.call("hit", 290)
		finish = false


var lastGuy = 0
func hit(damage: int, id: int) -> void:
	if id != lastGuy:
		health -= damage
		lastGuy = id
	if health <= 0 and !dead:
		die()

func die() -> void:
	SignalBus.updateResp.emit(true)
	Manager.deaths += 1
	dead = true
	$shader.material.set_shader_parameter("myOpaq", 8.0)

func _input(event):
	if finish:
		return
	if event.is_action_pressed("esc") and cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cameFollow = false
		cam.setCam(1)
		$hun.stop()
		SignalBus.emit_signal("paused")
		
	elif event.is_action_pressed("esc") and !cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true
		cam.setCam(0)
		$hun.unStop()
		SignalBus.emit_signal("unPaused")

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
	if dead or finish or gamePaused:
		return

	look_at(get_global_mouse_position())
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	if dir:
		moved = true
		position += dir * speed * delta
	else:
		velocity = Vector2(0, 0)

	move_and_slide()


func makeHunSave():
	$hun.saveWeapon()

func loading():
	gamePaused = true
	await get_tree().create_timer(.2).timeout
	gamePaused = false

	
func weaponGrabbed(which: int, currentAmmo: int) -> void:
	$hun.update_values(which, currentAmmo)
	SignalBus.updateAmmo.emit(currentAmmo)
	gunPickedUp = true
